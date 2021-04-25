#import "Eneko.h"

%group Lockscreen

%hook CSCoverSheetViewController

- (void)viewDidLoad { // add player to the lockscreen

	%orig;

	// player
	NSURL* url = [GcImagePickerUtils videoURLFromDefaults:@"love.litten.enekopreferences" withKey:@"lockscreenWallpaper"];
	if (!url) return;

    playerItemLS = [AVPlayerItem playerItemWithURL:url];

    playerLS = [AVQueuePlayer playerWithPlayerItem:playerItemLS];
    playerLS.volume = [lockscreenVolumeValue doubleValue];
	[playerLS setPreventsDisplaySleepDuringVideoPlayback:NO];
	if ([lockscreenVolumeValue doubleValue] == 0.0) [playerLS setMuted:YES];
	else [playerLS setVolume:[lockscreenVolumeValue doubleValue]];
	[[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryAmbient error:nil];

	playerLooperLS = [AVPlayerLooper playerLooperWithPlayer:playerLS templateItem:playerItemLS];

    playerLayerLS = [AVPlayerLayer playerLayerWithPlayer:playerLS];
    [playerLayerLS setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    [playerLayerLS setFrame:[[[self view] layer] bounds]];
	[playerLayerLS setOpacity:[lockscreenOpacityValue doubleValue]];
    [[[self view] layer] insertSublayer:playerLayerLS atIndex:0];


	// dim and blur superview
	if (!dimBlurViewLS && ([lockscreenBlurAmountValue doubleValue] != 0.0 || [lockscreenDimValue doubleValue] != 0.0)) {
		dimBlurViewLS = [[UIView alloc] initWithFrame:[[self view] bounds]];
		[dimBlurViewLS setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
		[[self view] insertSubview:dimBlurViewLS atIndex:1];
	}

	// blur
	if (!blurLS && [lockscreenBlurAmountValue doubleValue] != 0.0) {
		if ([lockscreenBlurModeValue intValue] == 0)
			blurLS = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
		else if ([lockscreenBlurModeValue intValue] == 1)
			blurLS = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];

		blurViewLS = [[UIVisualEffectView alloc] initWithEffect:blurLS];
		[blurViewLS setFrame:[dimBlurViewLS bounds]];
		[blurViewLS setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
		[blurViewLS setClipsToBounds:YES];
		[blurViewLS setAlpha:[lockscreenBlurAmountValue doubleValue]];
		[dimBlurViewLS addSubview:blurViewLS];
	}

	// dim
	if (!dimViewLS && [lockscreenDimValue doubleValue] != 0.0) {
		dimViewLS = [[UIView alloc] initWithFrame:[[self view] bounds]];
		[dimViewLS setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
		[dimViewLS setBackgroundColor:[UIColor blackColor]];
		[dimViewLS setAlpha:[lockscreenDimValue doubleValue]];
		[dimBlurViewLS addSubview:dimViewLS];
	}
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(adjustFrame) name:@"enekoRotateNotification" object:nil];

}

- (void)viewWillAppear:(BOOL)animated { // play when view appears

	%orig;

	isLockscreenVisible = YES;
	if ((hideWhenLowPowerSwitch && isOnLowPower) || isInCall) return;
	[self adjustFrame];
	[playerLS play];
	if (enableHomescreenWallpaperSwitch && isHomescreenVisible) [playerHS pause];

}

- (void)viewWillDisappear:(BOOL)animated { // pause when view disappears

	%orig;

	isLockscreenVisible = NO;
	if ((hideWhenLowPowerSwitch && isOnLowPower) || isInCall) return;
	[playerLS pause];
	if (enableHomescreenWallpaperSwitch && isHomescreenVisible) [playerHS play];

}

%new
- (void)adjustFrame { // adjust the frame
	
	[playerLayerLS setFrame:[[[self view] layer] bounds]];

}

%end

%hook SBControlCenterController

- (void)_willPresent { // pause when control center appears

	%orig;

	isControlCenterVisible = YES;
	if ((hideWhenLowPowerSwitch && isOnLowPower) || isInCall) return;
	if (isLockscreenVisible) [playerLS pause];

}

%end

%hook CCUIModularControlCenterOverlayViewController

- (void)dismissAnimated:(BOOL)arg1 withCompletionHandler:(id)arg2 { // pause when control center is being dismissed

	%orig;

	isControlCenterVisible = NO;
	if ((hideWhenLowPowerSwitch && isOnLowPower) || isInCall) return;
	if (isLockscreenVisible) [playerLS play];

}

%end

%end

%group Homescreen

%hook SBIconController

- (void)viewDidLoad { // add player to the homescreen

	%orig;

	// player
	NSURL* url = [GcImagePickerUtils videoURLFromDefaults:@"love.litten.enekopreferences" withKey:@"homescreenWallpaper"];
	if (!url) return;

    playerItemHS = [AVPlayerItem playerItemWithURL:url];

    playerHS = [AVQueuePlayer playerWithPlayerItem:playerItemHS];
    playerHS.volume = [homescreenVolumeValue doubleValue];
	[playerHS setPreventsDisplaySleepDuringVideoPlayback:NO];
	if ([homescreenVolumeValue doubleValue] == 0.0) [playerHS setMuted:YES];
	else [playerHS setVolume:[homescreenVolumeValue doubleValue]];
	[[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryAmbient error:nil];
	
	playerLooperHS = [AVPlayerLooper playerLooperWithPlayer:playerHS templateItem:playerItemHS];

    playerLayerHS = [AVPlayerLayer playerLayerWithPlayer:playerHS];
    [playerLayerHS setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    [playerLayerHS setFrame:[[[self view] layer] bounds]];
	[playerLayerHS setTransform:CATransform3DMakeScale(1.15, 1.15, 2)];
	[playerLayerHS setOpacity:[homescreenOpacityValue doubleValue]];
    [[[self view] layer] insertSublayer:playerLayerHS atIndex:0];


	// dim and blur superview
	if (!dimBlurViewHS && ([homescreenBlurAmountValue doubleValue] != 0.0 || [homescreenDimValue doubleValue] != 0.0)) {
		dimBlurViewHS = [[UIView alloc] initWithFrame:[[self view] bounds]];
		[[dimBlurViewHS layer] setTransform:CATransform3DMakeScale(1.15, 1.15, 2)];
		[dimBlurViewHS setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
		[[self view] insertSubview:dimBlurViewHS atIndex:1];
	}

	// blur
	if (!blurHS && [homescreenBlurAmountValue doubleValue] != 0.0) {
		if ([homescreenBlurModeValue intValue] == 0)
			blurHS = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
		else if ([homescreenBlurModeValue intValue] == 1)
			blurHS = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];

		blurViewHS = [[UIVisualEffectView alloc] initWithEffect:blurHS];
		[blurViewHS setFrame:[dimBlurViewHS bounds]];
		[blurViewHS setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
		[blurViewHS setClipsToBounds:YES];
		[blurViewHS setAlpha:[homescreenBlurAmountValue doubleValue]];
		[dimBlurViewHS addSubview:blurViewHS];
	}

	// dim
	if (!dimViewHS && [homescreenDimValue doubleValue] != 0.0) {
		dimViewHS = [[UIView alloc] initWithFrame:[[self view] bounds]];
		[dimViewHS setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
		[dimViewHS setBackgroundColor:[UIColor blackColor]];
		[dimViewHS setAlpha:[homescreenDimValue doubleValue]];
		[dimBlurViewHS addSubview:dimViewHS];
	}

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(adjustFrame) name:@"enekoRotateNotification" object:nil];

}

- (void)viewWillAppear:(BOOL)animated { // play when view appears

	%orig;

	isHomescreenVisible = YES;
	if ((hideWhenLowPowerSwitch && isOnLowPower) || isInCall) return;
	[self adjustFrame];
	[playerHS play];

}

- (void)viewWillDisappear:(BOOL)animated { // pause when view disappears

	%orig;

	isHomescreenVisible = NO;
	[playerHS pause];

}

%new
- (void)adjustFrame { // adjust the frame
	
	[playerLayerHS setFrame:[[[self view] layer] bounds]];

}

%end

%hook CSCoverSheetViewController

- (void)viewWillAppear:(BOOL)animated { // pause when lockscreen appears

	%orig;

	isLockscreenVisible = YES;
	if ((hideWhenLowPowerSwitch && isOnLowPower) || isInCall) return;
	if (isHomescreenVisible) [playerHS pause];

}

- (void)viewWillDisappear:(BOOL)animated { // play when lockscreen disappears

	%orig;

	isLockscreenVisible = NO;
	if ((hideWhenLowPowerSwitch && isOnLowPower) || isInCall) return;
	if (isHomescreenVisible) [playerHS play];

}

%end

%hook SBControlCenterController

- (void)_willPresent { // pause when control center appears

	%orig;

	isControlCenterVisible = YES;
	if ((hideWhenLowPowerSwitch && isOnLowPower) || isInCall) return;
	if (isHomescreenVisible) [playerHS pause];

}

%end

%hook CCUIModularControlCenterOverlayViewController

- (void)dismissAnimated:(BOOL)arg1 withCompletionHandler:(id)arg2 { // pause when control center is being dismissed

	%orig;

	isControlCenterVisible = NO;
	if ((hideWhenLowPowerSwitch && isOnLowPower) || isInCall) return;
	if (isHomescreenVisible) [playerHS play];

}

%end

%end

%group ControlCenter

%hook CCUIModularControlCenterOverlayViewController

- (void)viewDidLoad { // add player to the control center

	%orig;

	// player
	NSURL* url = [GcImagePickerUtils videoURLFromDefaults:@"love.litten.enekopreferences" withKey:@"controlCenterWallpaper"];
	if (!url) return;

    playerItemCC = [AVPlayerItem playerItemWithURL:url];

    playerCC = [AVQueuePlayer playerWithPlayerItem:playerItemCC];
    playerCC.volume = [controlCenterVolumeValue doubleValue];
	[playerCC setPreventsDisplaySleepDuringVideoPlayback:NO];
	if ([controlCenterVolumeValue doubleValue] == 0.0) [playerCC setMuted:YES];
	else [playerCC setVolume:[controlCenterVolumeValue doubleValue]];
	[[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryAmbient error:nil];

	playerLooperCC = [AVPlayerLooper playerLooperWithPlayer:playerCC templateItem:playerItemCC];

    playerLayerCC = [AVPlayerLayer playerLayerWithPlayer:playerCC];
    [playerLayerCC setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    [playerLayerCC setFrame:[[[self view] layer] bounds]];
	[playerLayerCC setOpacity:[controlCenterOpacityValue doubleValue]];
    [[[self view] layer] insertSublayer:playerLayerCC atIndex:1];


	// dim and blur superview
	if (!dimBlurViewCC && ([controlCenterBlurAmountValue doubleValue] != 0.0 || [controlCenterDimValue doubleValue] != 0.0)) {
		dimBlurViewCC = [[UIView alloc] initWithFrame:[[self view] bounds]];
		[dimBlurViewCC setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
		[[self view] insertSubview:dimBlurViewCC atIndex:2];
	}

	// blur
	if (!blurCC && [controlCenterBlurAmountValue doubleValue] != 0.0) {
		if ([controlCenterBlurModeValue intValue] == 0)
			blurCC = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
		else if ([controlCenterBlurModeValue intValue] == 1)
			blurCC = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];

		blurViewCC = [[UIVisualEffectView alloc] initWithEffect:blurCC];
		[blurViewCC setFrame:[dimBlurViewCC bounds]];
		[blurViewCC setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
		[blurViewCC setClipsToBounds:YES];
		[blurViewCC setAlpha:[controlCenterBlurAmountValue doubleValue]];
		[dimBlurViewCC addSubview:blurViewCC];
	}

	// dim
	if (!dimViewCC && [controlCenterDimValue doubleValue] != 0.0) {
		dimViewCC = [[UIView alloc] initWithFrame:[[self view] bounds]];
		[dimViewCC setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
		[dimViewCC setBackgroundColor:[UIColor blackColor]];
		[dimViewCC setAlpha:[controlCenterDimValue doubleValue]];
		[dimBlurViewCC addSubview:dimViewCC];
	}

}

- (void)viewWillAppear:(BOOL)animated { // adjust frame when control center appears

	%orig;

	isControlCenterVisible = YES;
	[self adjustFrame];

}

- (void)viewWillDisappear:(BOOL)animated { // pause when device respringed, for some reason it would play otherwise

	%orig;

	isControlCenterVisible = NO;
	[playerLayerCC setHidden:YES];
	if (dimBlurViewCC) [dimBlurViewCC setHidden:YES];
	[playerCC pause];

}

- (void)dismissAnimated:(BOOL)arg1 withCompletionHandler:(id)arg2 { // pause when control center is being dismissed

	%orig;

	isControlCenterVisible = NO;
	if ((hideWhenLowPowerSwitch && isOnLowPower) || isInCall) return;
	[playerLayerCC setHidden:YES];
	if (dimBlurViewCC) [dimBlurViewCC setHidden:YES];
	[playerCC pause];
	if (isLockscreenVisible && !isHomescreenVisible) {
		if (enableLockscreenWallpaperSwitch) [playerLS play];
		if (enableHomescreenWallpaperSwitch) [playerHS pause];
	} else if (!isLockscreenVisible && isHomescreenVisible) {
		if (enableHomescreenWallpaperSwitch) [playerHS play];
		if (enableLockscreenWallpaperSwitch) [playerLS pause];
	}

}

%new
- (void)adjustFrame { // adjust the frame
	
	[playerLayerCC setFrame:[[[self view] layer] bounds]];

}

%end

%hook SBControlCenterController

- (void)_willPresent { // play when control center appears

	%orig;

	isControlCenterVisible = YES;
	if ((hideWhenLowPowerSwitch && isOnLowPower) || isInCall) return;
	[playerCC play];
	[playerLayerCC setHidden:NO];
	if (dimBlurViewCC) [dimBlurViewCC setHidden:NO];
	if (enableLockscreenWallpaperSwitch && isLockscreenVisible) [playerLS pause];
	else if (enableHomescreenWallpaperSwitch && isHomescreenVisible) [playerHS pause];

}

%end

%end

%group Eneko

%hook SBBacklightController

- (void)turnOnScreenFullyWithBacklightSource:(long long)arg1 { // play when screen turned on

	%orig;

	screenIsOn = YES;
    if (!isLockscreenVisible) return;
	if ((hideWhenLowPowerSwitch && isOnLowPower) || isInCall) return;
	if (enableLockscreenWallpaperSwitch) [playerLS play];
	if (enableHomescreenWallpaperSwitch) [playerHS pause];
	if (enableControlCenterWallpaperSwitch) [playerCC pause];

}

%end

%hook SBLockScreenManager

- (void)lockUIFromSource:(int)arg1 withOptions:(id)arg2 { // pause all players when locked

	%orig;

	isLockscreenVisible = YES;
	screenIsOn = NO;
	if (enableLockscreenWallpaperSwitch) [playerLS pause];
	if (enableHomescreenWallpaperSwitch) [playerHS pause];
	if (enableControlCenterWallpaperSwitch) [playerCC pause];

}

%end

%hook SpringBoard

- (void)noteInterfaceOrientationChanged:(long long)arg1 duration:(double)arg2 logMessage:(id)arg3 { // send notification to change the frame when rotated

	%orig;

	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.001 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
		[[NSNotificationCenter defaultCenter] postNotificationName:@"enekoRotateNotification" object:nil];
	});

}

%end

%hook SBMediaController

- (BOOL)isPlaying { // mute players when music is playing

	if ([lockscreenVolumeValue doubleValue] == 0.0 && [homescreenVolumeValue doubleValue] == 0.0 && [controlCenterVolumeValue doubleValue] == 0.0) return %orig;

	BOOL orig = %orig;

	if (orig) {
		if (enableLockscreenWallpaperSwitch && [lockscreenVolumeValue doubleValue] != 0.0 && muteWhenMusicPlaysSwitch) [playerLS setVolume:0.0];
		if (enableHomescreenWallpaperSwitch && [homescreenVolumeValue doubleValue] != 0.0 && muteWhenMusicPlaysSwitch) [playerHS setVolume:0.0];
		if (enableControlCenterWallpaperSwitch && [controlCenterVolumeValue doubleValue] != 0.0 && muteWhenMusicPlaysSwitch) [playerCC setVolume:0.0];
	} else {
		if (enableLockscreenWallpaperSwitch && [lockscreenVolumeValue doubleValue] != 0.0 && muteWhenMusicPlaysSwitch) [playerLS setVolume:[lockscreenVolumeValue doubleValue]];
		if (enableHomescreenWallpaperSwitch && [homescreenVolumeValue doubleValue] != 0.0 && muteWhenMusicPlaysSwitch) [playerHS setVolume:[homescreenVolumeValue doubleValue]];
		if (enableControlCenterWallpaperSwitch && [controlCenterVolumeValue doubleValue] != 0.0 && muteWhenMusicPlaysSwitch) [playerCC setVolume:[controlCenterVolumeValue doubleValue]];
	}

	return orig;

}

%end

%hook TUCall

- (int)status { // pause when user is getting a call and play when the call ends

	if (hideWhenLowPowerSwitch && isOnLowPower) return %orig;

	int orig = %orig;

	if (orig != 6) {
		isInCall = YES;
		if (enableLockscreenWallpaperSwitch) [playerLS pause];
		if (enableHomescreenWallpaperSwitch) [playerHS pause];
		if (enableControlCenterWallpaperSwitch) [playerCC pause];
	} else if (orig == 6) {
		isInCall = NO;
		if (isLockscreenVisible && !isHomescreenVisible) {
			if (enableLockscreenWallpaperSwitch && screenIsOn) [playerLS play];
			if (enableHomescreenWallpaperSwitch) [playerHS pause];
		} else if (!isLockscreenVisible && isHomescreenVisible) {
			if (enableHomescreenWallpaperSwitch) [playerHS play];
			if (enableLockscreenWallpaperSwitch) [playerLS pause];
		}
		[playerCC pause];
	}

	return orig;

}

%end

%hook SiriUIBackgroundBlurView

- (void)removeFromSuperview { // play when siri was dismissed (ios 14)

	%orig;

	if ((hideWhenLowPowerSwitch && isOnLowPower) || isInCall) return;

	if (enableLockscreenWallpaperSwitch && isLockscreenVisible && !isHomescreenVisible) [playerLS play];
	else if (enableHomescreenWallpaperSwitch && isHomescreenVisible && !isLockscreenVisible) [playerHS play];
	[playerCC pause];

}

%end

%hook SiriUISiriStatusView

- (void)removeFromSuperview { // play when siri was dismissed (ios 13)

	%orig;

	if ((hideWhenLowPowerSwitch && isOnLowPower) || isInCall) return;

	if (enableLockscreenWallpaperSwitch && isLockscreenVisible && !isHomescreenVisible) [playerLS play];
	else if (enableHomescreenWallpaperSwitch && isHomescreenVisible && !isLockscreenVisible) [playerHS play];
	[playerCC pause];

}

%end

%hook SBDashBoardCameraPageViewController

- (void)viewWillAppear:(BOOL)animated { // pause when lockscreen camera appears

	%orig;

	if ((hideWhenLowPowerSwitch && isOnLowPower) || isInCall) return;
	if (enableLockscreenWallpaperSwitch && isLockscreenVisible) [playerLS pause];
	isLockscreenVisible = NO;

}

- (void)viewWillDisappear:(BOOL)animated { // play when lockscreen camera disappears

	isLockscreenVisible = YES;
	if ((hideWhenLowPowerSwitch && isOnLowPower) || isInCall) return;
	if (enableLockscreenWallpaperSwitch && isLockscreenVisible) [playerLS play];

}

%end

%hook CSModalButton

- (void)didMoveToWindow { // pause when alarm/timer fires

	%orig;

	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
		if (enableLockscreenWallpaperSwitch) [playerLS pause];
		if (enableHomescreenWallpaperSwitch) [playerHS pause];
		if (enableControlCenterWallpaperSwitch) [playerCC pause];
	});

}

- (void)removeFromSuperview { // pause when alarm/timer was dismissed

	%orig;

	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
		if (enableLockscreenWallpaperSwitch && screenIsOn) [playerLS play];
		if (enableHomescreenWallpaperSwitch) [playerHS pause];
		if (enableControlCenterWallpaperSwitch) [playerCC pause];
	});

}

%end

%hook SBLockScreenEmergencyCallViewController

- (void)viewWillAppear:(BOOL)animated { // pause when emergency call pad appears

	%orig;

	isLockscreenVisible = NO;
	if (enableLockscreenWallpaperSwitch) [playerLS pause];

}

- (void)viewWillDisappear:(BOOL)animated { // play when emergency call pad disappears

	%orig;

	isLockscreenVisible = YES;
	if ((hideWhenLowPowerSwitch && isOnLowPower) || isInCall) return;
	if (enableLockscreenWallpaperSwitch) [playerLS play];

}

%end

%hook NSProcessInfo

- (BOOL)isLowPowerModeEnabled { // hide when low power mode is enabled

	if (!hideWhenLowPowerSwitch) return %orig;
	
	if (!supportsLowPowerMode) {
		isOnLowPower = NO;
		return %orig;
	}

	isOnLowPower = %orig;
	
	if (isOnLowPower) {
		dispatch_async(dispatch_get_main_queue(), ^{
			if (enableLockscreenWallpaperSwitch) {
				[playerLayerLS setHidden:YES];
				if (dimBlurViewLS) [dimBlurViewLS setHidden:YES];
				[playerLS pause];
			}
			if (enableHomescreenWallpaperSwitch) {
				[playerLayerHS setHidden:YES];
				if (dimBlurViewHS) [dimBlurViewHS setHidden:YES];
				[playerHS pause];
			}
			if (enableControlCenterWallpaperSwitch) {
				[playerLayerCC setHidden:YES];
				if (dimBlurViewCC) [dimBlurViewCC setHidden:YES];
				[playerCC pause];
			}
		});
	} else {
		dispatch_async(dispatch_get_main_queue(), ^{
			if (enableLockscreenWallpaperSwitch && isLockscreenVisible && !isControlCenterVisible) [playerLS play];
			else if (enableHomescreenWallpaperSwitch && isHomescreenVisible && !isControlCenterVisible) [playerHS play];
			else if (enableControlCenterWallpaperSwitch && isControlCenterVisible) [playerCC play];
			[playerLayerLS setHidden:NO];
			[playerLayerHS setHidden:NO];
			[playerLayerCC setHidden:NO];
			if (dimBlurViewLS) [dimBlurViewLS setHidden:NO];
			if (dimBlurViewHS) [dimBlurViewHS setHidden:NO];
		});
	}

	return isOnLowPower;

}

%end

%end

%ctor {

	preferences = [[HBPreferences alloc] initWithIdentifier:@"love.litten.enekopreferences"];

	[preferences registerBool:&enabled default:NO forKey:@"Enabled"];
	if (!enabled) return;

	// lockscreen
	[preferences registerBool:&enableLockscreenWallpaperSwitch default:NO forKey:@"enableLockscreenWallpaper"];
	if (enableLockscreenWallpaperSwitch) {
		[preferences registerObject:&lockscreenVolumeValue default:@"0.0" forKey:@"lockscreenVolume"];
		[preferences registerObject:&lockscreenBlurAmountValue default:@"0.0" forKey:@"lockscreenBlurAmount"];
		[preferences registerObject:&lockscreenBlurModeValue default:@"0" forKey:@"lockscreenBlurMode"];
		[preferences registerObject:&lockscreenDimValue default:@"0.0" forKey:@"lockscreenDim"];
		[preferences registerObject:&lockscreenOpacityValue default:@"1.0" forKey:@"lockscreenOpacity"];
	}

	// homescreen
	[preferences registerBool:&enableHomescreenWallpaperSwitch default:NO forKey:@"enableHomescreenWallpaper"];
	if (enableHomescreenWallpaperSwitch) {
		[preferences registerObject:&homescreenVolumeValue default:@"0.0" forKey:@"homescreenVolume"];
		[preferences registerObject:&homescreenBlurAmountValue default:@"0.0" forKey:@"homescreenBlurAmount"];
		[preferences registerObject:&homescreenBlurModeValue default:@"0" forKey:@"homescreenBlurMode"];
		[preferences registerObject:&homescreenDimValue default:@"0.0" forKey:@"homescreenDim"];
		[preferences registerObject:&homescreenOpacityValue default:@"1.0" forKey:@"homescreenOpacity"];
	}

	// control center
	[preferences registerBool:&enableControlCenterWallpaperSwitch default:NO forKey:@"enableControlCenterWallpaper"];
	if (enableControlCenterWallpaperSwitch) {
		[preferences registerObject:&controlCenterVolumeValue default:@"0.0" forKey:@"controlCenterVolume"];
		[preferences registerObject:&controlCenterBlurAmountValue default:@"0.0" forKey:@"controlCenterBlurAmount"];
		[preferences registerObject:&controlCenterBlurModeValue default:@"0" forKey:@"controlCenterBlurMode"];
		[preferences registerObject:&controlCenterDimValue default:@"0.0" forKey:@"controlCenterDim"];
		[preferences registerObject:&controlCenterOpacityValue default:@"1.0" forKey:@"controlCenterOpacity"];
	}

	// miscellaneous
	[preferences registerBool:&muteWhenMusicPlaysSwitch default:YES forKey:@"muteWhenMusicPlays"];
	[preferences registerBool:&hideWhenLowPowerSwitch default:YES forKey:@"hideWhenLowPower"];

	struct utsname systemInfo;
    uname(&systemInfo);
    NSString* deviceModel = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
	if ([deviceModel containsString:@"iPhone"]) supportsLowPowerMode = YES;

	if (enableLockscreenWallpaperSwitch) %init(Lockscreen);
	if (enableHomescreenWallpaperSwitch) %init(Homescreen);
	if (enableControlCenterWallpaperSwitch) %init(ControlCenter);
	if (enableLockscreenWallpaperSwitch || enableHomescreenWallpaperSwitch || enableControlCenterWallpaperSwitch) %init(Eneko);

}