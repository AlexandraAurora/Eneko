#import <UIKit/UIKit.h>
#import <Preferences/PSListController.h>
#import <Preferences/PSSpecifier.h>
#import <SafariServices/SafariServices.h>
#import "../PreferenceKeys.h"
#import "../NotificationKeys.h"
#import <rootless.h>

@interface EnekoRootListController : PSListController <SFSafariViewControllerDelegate>
@end

@interface NSTask : NSObject
@property(copy)NSArray* arguments;
@property(copy)NSString* launchPath;
- (void)launch;
@end
