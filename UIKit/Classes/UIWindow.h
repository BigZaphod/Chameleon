//  Created by Sean Heber on 5/27/10.
#import "UIView.h"

typedef CGFloat UIWindowLevel;
extern const UIWindowLevel UIWindowLevelNormal;
extern const UIWindowLevel UIWindowLevelAlert;
extern const UIWindowLevel UIWindowLevelStatusBar;

extern NSString *const UIWindowDidBecomeVisibleNotification;
extern NSString *const UIWindowDidBecomeHiddenNotification;
extern NSString *const UIWindowDidBecomeKeyNotification;
extern NSString *const UIWindowDidResignKeyNotification;
extern NSString *const UIKeyboardWillShowNotification;
extern NSString *const UIKeyboardDidShowNotification;
extern NSString *const UIKeyboardWillHideNotification;
extern NSString *const UIKeyboardDidHideNotification;
extern NSString *const UIKeyboardBoundsUserInfoKey;

@class UIScreen;

@interface UIWindow : UIView {
@private
	UIScreen *_screen;
	__weak UIResponder *_firstResponder;
	NSUndoManager *_undoManager;
}

- (CGPoint)convertPoint:(CGPoint)toConvert toWindow:(UIWindow *)toWindow;
- (CGPoint)convertPoint:(CGPoint)toConvert fromWindow:(UIWindow *)fromWindow;
- (CGRect)convertRect:(CGRect)toConvert fromWindow:(UIWindow *)fromWindow;
- (CGRect)convertRect:(CGRect)toConvert toWindow:(UIWindow *)toWindow;

- (void)makeKeyWindow;
- (void)makeKeyAndVisible;
- (void)resignKeyWindow;
- (void)becomeKeyWindow;
- (void)sendEvent:(UIEvent *)event;

@property (nonatomic, readonly, getter=isKeyWindow) BOOL keyWindow;
@property (nonatomic, retain) UIScreen *screen;
@property (nonatomic, assign) UIWindowLevel windowLevel;

@end
