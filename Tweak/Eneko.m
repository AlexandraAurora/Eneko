//
//  Eneko.m
//  Eneko
//
//  Created by Alexandra (@Traurige)
//

#import "Eneko.h"

#pragma mark - Lock screen class hooks

static void (* orig_CSCoverSheetViewController_viewDidLoad)(CSCoverSheetViewController* self, SEL _cmd);
static void override_CSCoverSheetViewController_viewDidLoad(CSCoverSheetViewController* self, SEL _cmd) {
    orig_CSCoverSheetViewController_viewDidLoad(self, _cmd);

    // player
    NSURL* url = [GcImagePickerUtils videoURLFromDefaults:kPreferencesIdentifier withKey:kPreferenceKeyLockScreenWallpaper];
    if (!url) {
        return;
    }

    lockScreenPlayerItem = [AVPlayerItem playerItemWithURL:url];

    lockScreenPlayer = [AVQueuePlayer playerWithPlayerItem:lockScreenPlayerItem];
    [lockScreenPlayer setPreventsDisplaySleepDuringVideoPlayback:NO];

    if (pfLockScreenVolume == 0) {
        [lockScreenPlayer setMuted:YES];
    } else {
        [lockScreenPlayer setVolume:pfLockScreenVolume];
    }

    lockScreenPlayerLooper = [AVPlayerLooper playerLooperWithPlayer:lockScreenPlayer templateItem:lockScreenPlayerItem];

    lockScreenPlayerLayer = [AVPlayerLayer playerLayerWithPlayer:lockScreenPlayer];
    [lockScreenPlayerLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    [lockScreenPlayerLayer setFrame:[[[self view] layer] bounds]];
    [[[self view] layer] insertSublayer:lockScreenPlayerLayer atIndex:0];

    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryAmbient error:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(adjustFrame) name:@"enekoScreenRotated" object:nil];
}

static void CSCoverSheetViewController_adjustFrame(CSCoverSheetViewController* self, SEL _cmd) {
    [lockScreenPlayerLayer setFrame:[[[self view] layer] bounds]];
}

#pragma mark - Home screen class hooks

static void (* orig_SBIconController_viewDidLoad)(SBIconController* self, SEL _cmd);
static void override_SBIconController_viewDidLoad(SBIconController* self, SEL _cmd) {
    orig_SBIconController_viewDidLoad(self, _cmd);

    // player
    NSURL* url = [GcImagePickerUtils videoURLFromDefaults:kPreferencesIdentifier withKey:kPreferenceKeyHomeScreenWallpaper];
    if (!url) {
        return;
    }

    homeScreenPlayerItem = [AVPlayerItem playerItemWithURL:url];

    homeScreenPlayer = [AVQueuePlayer playerWithPlayerItem:homeScreenPlayerItem];
    [homeScreenPlayer setPreventsDisplaySleepDuringVideoPlayback:NO];

    if (pfHomeScreenVolume == 0) {
        [homeScreenPlayer setMuted:YES];
    } else {
        [homeScreenPlayer setVolume:pfHomeScreenVolume];
    }

    homeScreenPlayerLooper = [AVPlayerLooper playerLooperWithPlayer:homeScreenPlayer templateItem:homeScreenPlayerItem];

    homeScreenPlayerLayer = [AVPlayerLayer playerLayerWithPlayer:homeScreenPlayer];
    [homeScreenPlayerLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    [homeScreenPlayerLayer setFrame:[[[self view] layer] bounds]];

    if (pfZoomWallpaper) {
        [homeScreenPlayerLayer setTransform:CATransform3DMakeScale(1.15, 1.15, 2)];
    }

    [[[self view] layer] insertSublayer:homeScreenPlayerLayer atIndex:0];

    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryAmbient error:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(adjustFrame) name:@"enekoScreenRotated" object:nil];
}

static void SBIconController_adjustFrame(SBIconController* self, SEL _cmd) {
    [homeScreenPlayerLayer setFrame:[[[self view] layer] bounds]];
}

#pragma mark - Manangement class hooks

static void (* orig_CSCoverSheetViewController_viewWillAppear)(CSCoverSheetViewController* self, SEL _cmd, BOOL animated);
static void override_CSCoverSheetViewController_viewWillAppear(CSCoverSheetViewController* self, SEL _cmd, BOOL animated) {
    orig_CSCoverSheetViewController_viewWillAppear(self, _cmd, animated);

    isLockScreenVisible = YES;

    if ((pfDisableInLowPowerMode && isInLowPowerMode) || isInCall) {
        return;
    }

    if (lockScreenPlayer) {
        [self adjustFrame];
        [lockScreenPlayer play];
    }

    if (homeScreenPlayer && isHomeScreenVisible) {
        [homeScreenPlayer pause];
    }
}

static void (* orig_CSCoverSheetViewController_viewWillDisappear)(CSCoverSheetViewController* self, SEL _cmd, BOOL animated);
static void override_CSCoverSheetViewController_viewWillDisappear(CSCoverSheetViewController* self, SEL _cmd, BOOL animated) {
    orig_CSCoverSheetViewController_viewWillDisappear(self, _cmd, animated);

    isLockScreenVisible = NO;

    if ((pfDisableInLowPowerMode && isInLowPowerMode) || isInCall) {
        return;
    }

    if (lockScreenPlayer) {
        [lockScreenPlayer pause];
    }

    if (homeScreenPlayer && isHomeScreenVisible) {
        [homeScreenPlayer play];
    }
}

static void (* orig_SBIconController_viewWillAppear)(SBIconController* self, SEL _cmd, BOOL animated);
static void override_SBIconController_viewWillAppear(SBIconController* self, SEL _cmd, BOOL animated) {
    orig_SBIconController_viewWillAppear(self, _cmd, animated);

    isHomeScreenVisible = YES;

    if ((pfDisableInLowPowerMode && isInLowPowerMode) || isInCall) {
        return;
    }

    if (homeScreenPlayer) {
        [self adjustFrame];
        [homeScreenPlayer play];
    }

    if (lockScreenPlayer && isLockScreenVisible) {
        [lockScreenPlayer pause];
    }
}

static void (* orig_SBIconController_viewWillDisappear)(SBIconController* self, SEL _cmd, BOOL animated);
static void override_SBIconController_viewWillDisappear(SBIconController* self, SEL _cmd, BOOL animated) {
    orig_SBIconController_viewWillDisappear(self, _cmd, animated);

    isHomeScreenVisible = NO;

    if ((pfDisableInLowPowerMode && isInLowPowerMode) || isInCall) {
        return;
    }

    if (homeScreenPlayer) {
        [homeScreenPlayer pause];
    }

    if (lockScreenPlayer && isLockScreenVisible) {
        [lockScreenPlayer play];
    }
}

static void (* orig_CCUIModularControlCenterOverlayViewController_viewWillAppear)(CCUIModularControlCenterOverlayViewController* self, SEL _cmd, BOOL animated);
static void override_CCUIModularControlCenterOverlayViewController_viewWillAppear(CCUIModularControlCenterOverlayViewController* self, SEL _cmd, BOOL animated) {
    orig_CCUIModularControlCenterOverlayViewController_viewWillAppear(self, _cmd, animated);

    if ((pfDisableInLowPowerMode && isInLowPowerMode) || isInCall) {
        return;
    }

    if (lockScreenPlayer && isLockScreenVisible) {
        [lockScreenPlayer pause];
    }

    if (homeScreenPlayer && isHomeScreenVisible) {
        [homeScreenPlayer pause];
    }
}

static void (* orig_CCUIModularControlCenterOverlayViewController_viewWillDisappear)(CCUIModularControlCenterOverlayViewController* self, SEL _cmd, BOOL animated);
static void override_CCUIModularControlCenterOverlayViewController_viewWillDisappear(CCUIModularControlCenterOverlayViewController* self, SEL _cmd, BOOL animated) {
    orig_CCUIModularControlCenterOverlayViewController_viewWillDisappear(self, _cmd, animated);

    if ((pfDisableInLowPowerMode && isInLowPowerMode) || isInCall) {
        return;
    }

    if (lockScreenPlayer && isLockScreenVisible) {
        [lockScreenPlayer play];
    }

    if (homeScreenPlayer && isHomeScreenVisible) {
        [homeScreenPlayer play];
    }
}

static void (* orig_SBBacklightController_turnOnScreenFullyWithBacklightSource)(SBBacklightController* self, SEL _cmd, int source);
static void override_SBBacklightController_turnOnScreenFullyWithBacklightSource(SBBacklightController* self, SEL _cmd, int source) {
    orig_SBBacklightController_turnOnScreenFullyWithBacklightSource(self, _cmd, source);

    if (isScreenOn) {
        return;
    }

    isScreenOn = YES;
    isLockScreenVisible = YES;

    if ((pfDisableInLowPowerMode && isInLowPowerMode) || isInCall) {
        return;
    }

    if (lockScreenPlayer) {
        [lockScreenPlayer play];
    }

    if (homeScreenPlayer) {
        [homeScreenPlayer pause];
    }
}

static void (* orig_SBLockScreenManager_lockUIFromSource_withOptions)(SBLockScreenManager* self, SEL _cmd, int source, id options);
static void override_SBLockScreenManager_lockUIFromSource_withOptions(SBLockScreenManager* self, SEL _cmd, int source, id options) {
    orig_SBLockScreenManager_lockUIFromSource_withOptions(self, _cmd, source, options);

    isScreenOn = NO;

    if (lockScreenPlayer) {
        [lockScreenPlayer pause];
    }

    if (homeScreenPlayer) {
        [homeScreenPlayer pause];
    }
}

static void (* orig_SpringBoard_noteInterfaceOrientationChanged_duration_logMessage)(SpringBoard* self, SEL _cmd, long long orientation, double duration, NSString* logMessage);
static void override_SpringBoard_noteInterfaceOrientationChanged_duration_logMessage(SpringBoard* self, SEL _cmd, long long orientation, double duration, NSString* logMessage) {
    orig_SpringBoard_noteInterfaceOrientationChanged_duration_logMessage(self, _cmd, orientation, duration, logMessage);

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.001 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"enekoScreenRotated" object:nil];
    });
}

static BOOL (* orig_SBMediaController_isPlaying)(SBMediaController* self, SEL _cmd);
static BOOL override_SBMediaController_isPlaying(SBMediaController* self, SEL _cmd) {
    if (pfLockScreenVolume == 0 && pfHomeScreenVolume == 0) {
        return orig_SBMediaController_isPlaying(self, _cmd);
    }

    BOOL orig = orig_SBMediaController_isPlaying(self, _cmd);

    if (orig) {
        if (lockScreenPlayer && ![lockScreenPlayer isMuted] && pfMuteWhenMusicPlays) {
            [lockScreenPlayer setVolume:0];
        }

        if (homeScreenPlayer && ![homeScreenPlayer isMuted] && pfMuteWhenMusicPlays) {
            [homeScreenPlayer setVolume:0];
        }
    } else {
        if (lockScreenPlayer && ![lockScreenPlayer isMuted] && pfMuteWhenMusicPlays) {
            [lockScreenPlayer setVolume:pfLockScreenVolume];
        }

        if (homeScreenPlayer && ![homeScreenPlayer isMuted] && pfMuteWhenMusicPlays) {
            [homeScreenPlayer setVolume:pfHomeScreenVolume];
        }
    }

    return orig;
}

static int (* orig_TUCall_status)(TUCall* self, SEL _cmd);
static int override_TUCall_status(TUCall* self, SEL _cmd) {
    if (pfDisableInLowPowerMode && isInLowPowerMode) {
        return orig_TUCall_status(self, _cmd);
    }

    int orig = orig_TUCall_status(self, _cmd);

    if (orig != 6) {
        isInCall = YES;

        if (lockScreenPlayer) {
            [lockScreenPlayer pause];
        }

        if (homeScreenPlayer) {
            [homeScreenPlayer pause];
        }
    } else if (orig == 6) {
        isInCall = NO;

        if (isLockScreenVisible && !isHomeScreenVisible) {
            if (lockScreenPlayer) {
                [lockScreenPlayer play];
            }

            if (homeScreenPlayer) {
                [homeScreenPlayer pause];
            }
        } else if (!isLockScreenVisible && isHomeScreenVisible) {
            if (homeScreenPlayer) {
                [homeScreenPlayer play];
            }

            if (lockScreenPlayer) {
                [lockScreenPlayer pause];
            }
        }
    }

    return orig;
}

static void (* orig_SiriUIBackgroundBlurView_removeFromSuperview)(SiriUIBackgroundBlurView* self, SEL _cmd);
static void override_SiriUIBackgroundBlurView_removeFromSuperview(SiriUIBackgroundBlurView* self, SEL _cmd) {
    orig_SiriUIBackgroundBlurView_removeFromSuperview(self, _cmd);

    if ((pfDisableInLowPowerMode && isInLowPowerMode) || isInCall) {
        return;
    }

    if (lockScreenPlayer && isLockScreenVisible && !isHomeScreenVisible) {
        [lockScreenPlayer play];
    } else if (homeScreenPlayer && isHomeScreenVisible && !isLockScreenVisible) {
        [homeScreenPlayer play];
    }
}

static void (* orig_SBDashBoardCameraPageViewController_viewWillAppear)(SBDashBoardCameraPageViewController* self, SEL _cmd, BOOL animated);
static void override_SBDashBoardCameraPageViewController_viewWillAppear(SBDashBoardCameraPageViewController* self, SEL _cmd, BOOL animated) {
    orig_SBDashBoardCameraPageViewController_viewWillAppear(self, _cmd, animated);

    if ((pfDisableInLowPowerMode && isInLowPowerMode) || isInCall) {
        return;
    }

    if (lockScreenPlayer && isLockScreenVisible) {
        [lockScreenPlayer pause];
    }

    isLockScreenVisible = NO;
}

static void (* orig_SBDashBoardCameraPageViewController_viewWillDisappear)(SBDashBoardCameraPageViewController* self, SEL _cmd, BOOL animated);
static void override_SBDashBoardCameraPageViewController_viewWillDisappear(SBDashBoardCameraPageViewController* self, SEL _cmd, BOOL animated) {
    orig_SBDashBoardCameraPageViewController_viewWillDisappear(self, _cmd, animated);

    isLockScreenVisible = YES;

    if ((pfDisableInLowPowerMode && isInLowPowerMode) || isInCall) {
        return;
    }

    if (lockScreenPlayer && isLockScreenVisible) {
        [lockScreenPlayer play];
    }
}

static void (* orig_CSModalButton_didMoveToWindow)(CSModalButton* self, SEL _cmd);
static void override_CSModalButton_didMoveToWindow(CSModalButton* self, SEL _cmd) {
    orig_CSModalButton_didMoveToWindow(self, _cmd);

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        if (lockScreenPlayer) {
            [lockScreenPlayer pause];
        }

        if (homeScreenPlayer) {
            [homeScreenPlayer pause];
        }
    });
}

static void (* orig_CSModalButton_removeFromSuperview)(CSModalButton* self, SEL _cmd);
static void override_CSModalButton_removeFromSuperview(CSModalButton* self, SEL _cmd) {
    orig_CSModalButton_removeFromSuperview(self, _cmd);

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        if (lockScreenPlayer) {
            [lockScreenPlayer play];
        }

        if (homeScreenPlayer) {
            [homeScreenPlayer pause];
        }
    });
}

static void (* orig_SBLockScreenEmergencyCallViewController_viewWillAppear)(SBLockScreenEmergencyCallViewController* self, SEL _cmd, BOOL animated);
static void override_SBLockScreenEmergencyCallViewController_viewWillAppear(SBLockScreenEmergencyCallViewController* self, SEL _cmd, BOOL animated) {
    orig_SBLockScreenEmergencyCallViewController_viewWillAppear(self, _cmd, animated);

    isLockScreenVisible = NO;

    if (lockScreenPlayer) {
        [lockScreenPlayer pause];
    }
}

static void (* orig_SBLockScreenEmergencyCallViewController_viewWillDisappear)(SBLockScreenEmergencyCallViewController* self, SEL _cmd, BOOL animated);
static void override_SBLockScreenEmergencyCallViewController_viewWillDisappear(SBLockScreenEmergencyCallViewController* self, SEL _cmd, BOOL animated) {
    orig_SBLockScreenEmergencyCallViewController_viewWillDisappear(self, _cmd, animated);

    isLockScreenVisible = YES;

    if ((pfDisableInLowPowerMode && isInLowPowerMode) || isInCall) {
        return;
    }

    if (lockScreenPlayer) {
        [lockScreenPlayer play];
    }
}

static BOOL (* orig_NSProcessInfo_isLowPowerModeEnabled)(NSProcessInfo* self, SEL _cmd);
static BOOL override_NSProcessInfo_isLowPowerModeEnabled(NSProcessInfo* self, SEL _cmd) {

    if (!pfDisableInLowPowerMode) {
        return orig_NSProcessInfo_isLowPowerModeEnabled(self, _cmd);
    }

    isInLowPowerMode = orig_NSProcessInfo_isLowPowerModeEnabled(self, _cmd);

    if (isInLowPowerMode) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (lockScreenPlayer) {
                [lockScreenPlayerLayer setHidden:YES];
                [lockScreenPlayer pause];
            }

            if (homeScreenPlayer) {
                [homeScreenPlayerLayer setHidden:YES];
                [homeScreenPlayer pause];
            }
        });
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (lockScreenPlayer && isLockScreenVisible) {
                [lockScreenPlayer play];
                [lockScreenPlayerLayer setHidden:NO];
            } else if (homeScreenPlayer && isHomeScreenVisible) {
                [homeScreenPlayer play];
                [homeScreenPlayerLayer setHidden:NO];
            }
        });
    }

    return isInLowPowerMode;
}

#pragma mark - Preferences

static void load_preferences() {
    preferences = [[NSUserDefaults alloc] initWithSuiteName:kPreferencesIdentifier];

    [preferences registerDefaults:@{
        kPreferenceKeyEnabled: @(kPreferenceKeyEnabledDefaultValue),
        kPreferenceKeyEnableLockScreenWallpaper: @(kPreferenceKeyEnableLockScreenWallpaperDefaultValue),
        kPreferenceKeyLockScreenVolume: @(kPreferenceKeyLockScreenVolumeDefaultValue),
        kPreferenceKeyEnableHomeScreenWallpaper: @(kPreferenceKeyEnableHomeScreenWallpaperDefaultValue),
        kPreferenceKeyHomeScreenVolume: @(kPreferenceKeyHomeScreenVolumeDefaultValue),
        kPreferenceKeyZoomWallpaper: @(kPreferenceKeyZoomWallpaperDefaultValue),
        kPreferenceKeyMuteWhenMusicPlays: @(kPreferenceKeyMuteWhenMusicPlaysDefaultValue),
        kPreferenceKeyDisableInLowPowerMode: @(kPreferenceKeyDisableInLowPowerModeDefaultValue)
    }];

    pfEnabled = [[preferences objectForKey:kPreferenceKeyEnabled] boolValue];
    pfEnableLockScreenWallpaper = [[preferences objectForKey:kPreferenceKeyEnableLockScreenWallpaper] boolValue];
    pfLockScreenVolume = [[preferences objectForKey:kPreferenceKeyLockScreenVolume] floatValue];
    pfEnableHomeScreenWallpaper = [[preferences objectForKey:kPreferenceKeyEnableHomeScreenWallpaper] boolValue];
    pfHomeScreenVolume = [[preferences objectForKey:kPreferenceKeyHomeScreenVolume] floatValue];
    pfZoomWallpaper = [[preferences objectForKey:kPreferenceKeyZoomWallpaper] boolValue];
    pfMuteWhenMusicPlays = [[preferences objectForKey:kPreferenceKeyMuteWhenMusicPlays] boolValue];
    pfDisableInLowPowerMode = [[preferences objectForKey:kPreferenceKeyDisableInLowPowerMode] boolValue];
}

__attribute((constructor)) static void initialize() {
    load_preferences();

    if (!pfEnabled) {
        return;
    }

    if (pfEnableLockScreenWallpaper) {
        class_addMethod(objc_getClass("CSCoverSheetViewController"), @selector(adjustFrame), (IMP)&CSCoverSheetViewController_adjustFrame, "v@:");
        MSHookMessageEx(objc_getClass("CSCoverSheetViewController"), @selector(viewDidLoad), (IMP)&override_CSCoverSheetViewController_viewDidLoad, (IMP *)&orig_CSCoverSheetViewController_viewDidLoad);
    }

    if (pfEnableHomeScreenWallpaper) {
        class_addMethod(objc_getClass("SBIconController"), @selector(adjustFrame), (IMP)&SBIconController_adjustFrame, "v@:");
        MSHookMessageEx(objc_getClass("SBIconController"), @selector(viewDidLoad), (IMP)&override_SBIconController_viewDidLoad, (IMP *)&orig_SBIconController_viewDidLoad);
    }

    MSHookMessageEx(objc_getClass("CSCoverSheetViewController"), @selector(viewWillAppear:), (IMP)&override_CSCoverSheetViewController_viewWillAppear, (IMP *)&orig_CSCoverSheetViewController_viewWillAppear);
    MSHookMessageEx(objc_getClass("CSCoverSheetViewController"), @selector(viewWillDisappear:), (IMP)&override_CSCoverSheetViewController_viewWillDisappear, (IMP *)&orig_CSCoverSheetViewController_viewWillDisappear);
    MSHookMessageEx(objc_getClass("SBIconController"), @selector(viewWillAppear:), (IMP)&override_SBIconController_viewWillAppear, (IMP *)&orig_SBIconController_viewWillAppear);
    MSHookMessageEx(objc_getClass("SBIconController"), @selector(viewWillDisappear:), (IMP)&override_SBIconController_viewWillDisappear, (IMP *)&orig_SBIconController_viewWillDisappear);
    MSHookMessageEx(objc_getClass("CCUIModularControlCenterOverlayViewController"), @selector(viewWillAppear:), (IMP)&override_CCUIModularControlCenterOverlayViewController_viewWillAppear, (IMP *)&orig_CCUIModularControlCenterOverlayViewController_viewWillAppear);
    MSHookMessageEx(objc_getClass("CCUIModularControlCenterOverlayViewController"), @selector(viewWillDisappear:), (IMP)&override_CCUIModularControlCenterOverlayViewController_viewWillDisappear, (IMP *)&orig_CCUIModularControlCenterOverlayViewController_viewWillDisappear);
    MSHookMessageEx(objc_getClass("SBBacklightController"), @selector(turnOnScreenFullyWithBacklightSource:), (IMP)&override_SBBacklightController_turnOnScreenFullyWithBacklightSource, (IMP *)&orig_SBBacklightController_turnOnScreenFullyWithBacklightSource);
    MSHookMessageEx(objc_getClass("SBLockScreenManager"), @selector(lockUIFromSource:withOptions:), (IMP)&override_SBLockScreenManager_lockUIFromSource_withOptions, (IMP *)&orig_SBLockScreenManager_lockUIFromSource_withOptions);
    MSHookMessageEx(objc_getClass("SpringBoard"), @selector(noteInterfaceOrientationChanged:duration:logMessage:), (IMP)&override_SpringBoard_noteInterfaceOrientationChanged_duration_logMessage, (IMP *)&orig_SpringBoard_noteInterfaceOrientationChanged_duration_logMessage);
    MSHookMessageEx(objc_getClass("SBMediaController"), @selector(isPlaying), (IMP)&override_SBMediaController_isPlaying, (IMP *)&orig_SBMediaController_isPlaying);
    MSHookMessageEx(objc_getClass("TUCall"), @selector(status), (IMP)&override_TUCall_status, (IMP *)&orig_TUCall_status);
    MSHookMessageEx(objc_getClass("SiriUIBackgroundBlurView"), @selector(removeFromSuperview), (IMP)&override_SiriUIBackgroundBlurView_removeFromSuperview, (IMP *)&orig_SiriUIBackgroundBlurView_removeFromSuperview);
    MSHookMessageEx(objc_getClass("SBDashBoardCameraPageViewController"), @selector(viewWillAppear:), (IMP)&override_SBDashBoardCameraPageViewController_viewWillAppear, (IMP *)&orig_SBDashBoardCameraPageViewController_viewWillAppear);
    MSHookMessageEx(objc_getClass("SBDashBoardCameraPageViewController"), @selector(viewWillDisappear:), (IMP)&override_SBDashBoardCameraPageViewController_viewWillDisappear, (IMP *)&orig_SBDashBoardCameraPageViewController_viewWillDisappear);
    MSHookMessageEx(objc_getClass("CSModalButton"), @selector(didMoveToWindow), (IMP)&override_CSModalButton_didMoveToWindow, (IMP *)&orig_CSModalButton_didMoveToWindow);
    MSHookMessageEx(objc_getClass("CSModalButton"), @selector(removeFromSuperview), (IMP)&override_CSModalButton_removeFromSuperview, (IMP *)&orig_CSModalButton_removeFromSuperview);
    MSHookMessageEx(objc_getClass("SBLockScreenEmergencyCallViewController"), @selector(viewWillAppear:), (IMP)&override_SBLockScreenEmergencyCallViewController_viewWillAppear, (IMP *)&orig_SBLockScreenEmergencyCallViewController_viewWillAppear);
    MSHookMessageEx(objc_getClass("SBLockScreenEmergencyCallViewController"), @selector(viewWillDisappear:), (IMP)&override_SBLockScreenEmergencyCallViewController_viewWillDisappear, (IMP *)&orig_SBLockScreenEmergencyCallViewController_viewWillDisappear);
    MSHookMessageEx(objc_getClass("NSProcessInfo"), @selector(isLowPowerModeEnabled), (IMP)&override_NSProcessInfo_isLowPowerModeEnabled, (IMP *)&orig_NSProcessInfo_isLowPowerModeEnabled);

    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)load_preferences, (CFStringRef)kNotificationKeyPreferencesReload, NULL, (CFNotificationSuspensionBehavior)kNilOptions);
}
