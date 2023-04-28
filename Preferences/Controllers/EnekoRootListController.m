#include "EnekoRootListController.h"

@implementation EnekoRootListController
- (NSArray *)specifiers {
	if (!_specifiers) {
		_specifiers = [self loadSpecifiersFromPlistName:@"Root" target:self];
	}

	return _specifiers;
}

- (void)setPreferenceValue:(id)value specifier:(PSSpecifier *)specifier {
    [super setPreferenceValue:value specifier:specifier];

    if ([[specifier propertyForKey:@"key"] isEqualToString:kPreferenceKeyEnabled] ||
		[[specifier propertyForKey:@"key"] isEqualToString:kPreferenceKeyEnableLockScreenWallpaper] ||
		[[specifier propertyForKey:@"key"] isEqualToString:kPreferenceKeyLockScreenVolume] ||
		[[specifier propertyForKey:@"key"] isEqualToString:kPreferenceKeyEnableHomeScreenWallpaper] ||
		[[specifier propertyForKey:@"key"] isEqualToString:kPreferenceKeyHomeScreenVolume]
	) {
		[self promptToRespring];
    }
}

- (void)promptToRespring {
    UIAlertController* resetAlert = [UIAlertController alertControllerWithTitle:@"Eneko" message:@"This option requires a respring to apply. Do you want to respring now?" preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction* yesAction = [UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * action) {
        [self respring];
	}];

	UIAlertAction* noAction = [UIAlertAction actionWithTitle:@"No" style:UIAlertActionStyleCancel handler:nil];

	[resetAlert addAction:yesAction];
	[resetAlert addAction:noAction];

	[self presentViewController:resetAlert animated:YES completion:nil];
}

- (void)respring {
	NSArray* launchPaths = @[@"/usr/bin/killall", @"/var/jb/usr/bin/killall"];
	for (NSString* launchPath in launchPaths) {
		if ([[NSFileManager defaultManager] fileExistsAtPath:launchPath]) {
			NSTask* task = [[NSTask alloc] init];
			[task setLaunchPath:launchPath];
			[task setArguments:@[@"backboardd"]];
			[task launch];
		}
	}
}

- (void)resetPrompt {
    UIAlertController* resetAlert = [UIAlertController alertControllerWithTitle:@"Eneko" message:@"Are you sure you want to reset your preferences?" preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction* yesAction = [UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * action) {
        [self resetPreferences];
	}];

	UIAlertAction* noAction = [UIAlertAction actionWithTitle:@"No" style:UIAlertActionStyleCancel handler:nil];

	[resetAlert addAction:yesAction];
	[resetAlert addAction:noAction];

	[self presentViewController:resetAlert animated:YES completion:nil];
}

- (void)resetPreferences {
	NSUserDefaults* userDefaults = [[NSUserDefaults alloc] initWithSuiteName:kPreferencesIdentifier];
	for (NSString* key in [userDefaults dictionaryRepresentation]) {
		[userDefaults removeObjectForKey:key];
	}

	NSArray* paths = @[
		[NSString stringWithFormat:@"/var/mobile/Library/Preferences/%@/", kPreferencesIdentifier],
		[NSString stringWithFormat:@"/var/jb/var/mobile/Library/Preferences/%@/", kPreferencesIdentifier]
	];
	for (NSString* path in paths) {
		[[NSFileManager defaultManager] removeItemAtPath:path error:nil];
	}

	[self reloadSpecifiers];
	CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), (CFStringRef)kNotificationKeyPreferencesReload, nil, nil, YES);
}
@end
