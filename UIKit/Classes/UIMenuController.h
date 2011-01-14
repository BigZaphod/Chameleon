//  Created by Sean Heber on 8/31/10.
#import <Foundation/Foundation.h>

@class UIView, UIWindow;

@interface UIMenuController : NSObject {
@private
	NSArray *_menuItems;
	NSMutableArray *_enabledMenuItems;
	id _menu;
	CGRect _menuFrame;
	CGPoint _menuLocation;
	BOOL _rightAlignMenu;
	UIWindow *_window;
}

+ (UIMenuController *)sharedMenuController;

- (void)setMenuVisible:(BOOL)menuVisible animated:(BOOL)animated;
- (void)setTargetRect:(CGRect)targetRect inView:(UIView *)targetView;		// if targetRect is CGRectNull, the menu will appear wherever the mouse cursor was at the time this method was called
- (void)update;

@property (nonatomic, getter=isMenuVisible) BOOL menuVisible;
@property (copy) NSArray *menuItems;

// returned in screen coords of the screen that the view used in setTargetRect:inView: belongs to
// there's always a value here, but it's not likely to be terribly reliable except immidately after
// the menu is made visible. I have no intenstively tested what the real UIKit does in all the possible
// situations. You have been warned.
@property (nonatomic, readonly) CGRect menuFrame;

@end
