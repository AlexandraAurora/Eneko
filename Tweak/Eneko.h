#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>
#import <sys/utsname.h>
#import "GcUniversal/GcImagePickerUtils.h"
#import <Cephei/HBPreferences.h>

HBPreferences* preferences = nil;

BOOL enabled = NO;

BOOL isLockscreenVisible = NO;
BOOL isHomescreenVisible = NO;
BOOL isControlCenterVisible = NO;
BOOL isInCall = NO;
BOOL screenIsOn = YES;
BOOL isOnLowPower = NO;
BOOL supportsLowPowerMode = NO;

AVQueuePlayer* playerLS = nil;
AVPlayerItem* playerItemLS = nil;
AVPlayerLooper* playerLooperLS = nil;
AVPlayerLayer* playerLayerLS = nil;
UIView* dimBlurViewLS = nil;
UIVisualEffectView* blurViewLS = nil;
UIBlurEffect* blurLS = nil;
UIView* dimViewLS = nil;

AVQueuePlayer* playerHS = nil;
AVPlayerItem* playerItemHS = nil;
AVPlayerLooper* playerLooperHS = nil;
AVPlayerLayer* playerLayerHS = nil;
UIView* dimBlurViewHS = nil;
UIVisualEffectView* blurViewHS = nil;
UIBlurEffect* blurHS = nil;
UIView* dimViewHS = nil;

AVQueuePlayer* playerCC = nil;
AVPlayerItem* playerItemCC = nil;
AVPlayerLooper* playerLooperCC = nil;
AVPlayerLayer* playerLayerCC = nil;
UIView* dimBlurViewCC = nil;
UIVisualEffectView* blurViewCC = nil;
UIBlurEffect* blurCC = nil;
UIView* dimViewCC = nil;

// lockscreen
BOOL enableLockscreenWallpaperSwitch = NO;
NSString* lockscreenVolumeValue = @"0.0";
NSString* lockscreenBlurAmountValue = @"0.0";
NSString* lockscreenBlurModeValue = @"0";
NSString* lockscreenDimValue = @"0.0";
NSString* lockscreenOpacityValue = @"1.0";

// homescreen
BOOL enableHomescreenWallpaperSwitch = NO;
NSString* homescreenVolumeValue = @"0.0";
NSString* homescreenBlurAmountValue = @"0.0";
NSString* homescreenBlurModeValue = @"0";
NSString* homescreenDimValue = @"0.0";
NSString* homescreenOpacityValue = @"1.0";

// control center
BOOL enableControlCenterWallpaperSwitch = NO;
NSString* controlCenterVolumeValue = @"0.0";
NSString* controlCenterBlurAmountValue = @"0.0";
NSString* controlCenterBlurModeValue = @"0";
NSString* controlCenterDimValue = @"0.0";
NSString* controlCenterOpacityValue = @"1.0";

// miscellaneous
BOOL muteWhenMusicPlaysSwitch = YES;
BOOL hideWhenLowPowerSwitch = YES;

@interface CSCoverSheetViewController : UIViewController
- (void)adjustFrame;
@end

@interface SBIconController : UIViewController
- (void)adjustFrame;
@end

@interface CCUIModularControlCenterOverlayViewController : UIViewController
- (void)adjustFrame;
@end