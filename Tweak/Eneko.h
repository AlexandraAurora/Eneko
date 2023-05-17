//
//  Eneko.h
//  Eneko
//
//  Created by Alexandra (@Traurige)
//

#import <substrate.h>
#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>
#import "GcUniversal/GcImagePickerUtils.h"
#import "../Preferences/PreferenceKeys.h"
#import "../Preferences/NotificationKeys.h"

BOOL isLockScreenVisible = YES;
BOOL isHomeScreenVisible = NO;
BOOL isScreenOn = YES;
BOOL isInCall = NO;
BOOL isInLowPowerMode = NO;

AVQueuePlayer* lockScreenPlayer;
AVPlayerItem* lockScreenPlayerItem;
AVPlayerLooper* lockScreenPlayerLooper;
AVPlayerLayer* lockScreenPlayerLayer;

AVQueuePlayer* homeScreenPlayer;
AVPlayerItem* homeScreenPlayerItem;
AVPlayerLooper* homeScreenPlayerLooper;
AVPlayerLayer* homeScreenPlayerLayer;

NSUserDefaults* preferences;
BOOL pfEnabled;
BOOL pfEnableLockScreenWallpaper;
CGFloat pfLockScreenVolume;
BOOL pfEnableHomeScreenWallpaper;
CGFloat pfHomeScreenVolume;
BOOL pfZoomWallpaper;
BOOL pfMuteWhenMusicPlays;
BOOL pfDisableInLowPowerMode;

@interface CSCoverSheetViewController : UIViewController
- (void)adjustFrame;
@end

@interface SBIconController : UIViewController
- (void)adjustFrame;
@end

@interface CCUIModularControlCenterOverlayViewController : UIViewController
@end

@interface SBBacklightController : NSObject
@end

@interface SBLockScreenManager : NSObject
@end

@interface SpringBoard : UIApplication
@end

@interface SBMediaController : NSObject
@end

@interface TUCall : NSObject
@end

@interface SiriUIBackgroundBlurView : UIView
@end

@interface SBDashBoardCameraPageViewController : UIViewController
@end

@interface CSModalButton : UIButton
@end

@interface SBLockScreenEmergencyCallViewController : UIViewController
@end
