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
		[self respringPrompt];
    }
}

- (void)cataloguePrompt {
	UIAlertController* catalogueAlert = [UIAlertController alertControllerWithTitle:@"Choose Catalogue" message:nil preferredStyle:UIAlertControllerStyleActionSheet];

    UIAlertAction* myLiveWallpapersAction = [UIAlertAction actionWithTitle:@"MyLiveWallpapers" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        [self openCatalogueWithUrl:[NSURL URLWithString:@"https://mylivewallpapers.com"]];
    }];

    UIAlertAction* liveWallpapers4FreeAction = [UIAlertAction actionWithTitle:@"LiveWallpapers4Free" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        [self openCatalogueWithUrl:[NSURL URLWithString:@"https://livewallpapers4free.com"]];
    }];

    UIAlertAction* liveWallPAction = [UIAlertAction actionWithTitle:@"LiveWallP" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        [self openCatalogueWithUrl:[NSURL URLWithString:@"https://livewallp.com"]];
    }];

    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];

    [catalogueAlert addAction:myLiveWallpapersAction];
    [catalogueAlert addAction:liveWallpapers4FreeAction];
    [catalogueAlert addAction:liveWallPAction];
    [catalogueAlert addAction:cancelAction];

    [self presentViewController:catalogueAlert animated:YES completion:nil];
}

- (void)openCatalogueWithUrl:(NSURL *)url {
    SFSafariViewController* safariViewController = [[SFSafariViewController alloc] initWithURL:url];
    [safariViewController setDelegate:self];
    [self presentViewController:safariViewController animated:YES completion:nil];
}

- (void)respringPrompt {
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
	NSTask* task = [[NSTask alloc] init];
	[task setLaunchPath:ROOT_PATH_NS(@"/usr/bin/killall")];
	[task setArguments:@[@"backboardd"]];
	[task launch];
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

	NSString* path = [NSString stringWithFormat:@"/var/mobile/Library/Preferences/%@/", kPreferencesIdentifier];
	[[NSFileManager defaultManager] removeItemAtPath:ROOT_PATH_NS_VAR(path) error:nil];

	[self reloadSpecifiers];
	CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), (CFStringRef)kNotificationKeyPreferencesReload, nil, nil, YES);
}
@end
