#import <Preferences/PSListController.h>
#import <Preferences/PSSpecifier.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIView (DuoTwitterCell)
- (void)anchorTop:(nullable NSLayoutAnchor <NSLayoutYAxisAnchor *> *)top leading:(nullable NSLayoutAnchor <NSLayoutXAxisAnchor *> *)leading bottom:(nullable NSLayoutAnchor <NSLayoutYAxisAnchor *> *)bottom trailing:(nullable NSLayoutAnchor <NSLayoutXAxisAnchor *> *)trailing padding:(UIEdgeInsets)insets size:(CGSize)size ;
@end

NS_ASSUME_NONNULL_END

@interface DuoTwitterCell : PSTableCell
@end

@interface DuoTwitterCell () {
	NSString* _user;
	NSString* _user2;
	NSString* _accountNameOne;
	NSString* _displayNameOne;
	NSString* _accountNameTwo;
	NSString* _displayNameTwo;
}
@end