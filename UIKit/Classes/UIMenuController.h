//  Created by Sean Heber on 8/31/10.
#import <Foundation/Foundation.h>

@class UIView;

@interface UIMenuController : NSObject {
@private
	NSArray *_menuItems;
	NSMutableArray *_enabledMenuItems;
	id _menu;
}

+ (UIMenuController *)sharedMenuController;

- (void)setMenuVisible:(BOOL)menuVisible animated:(BOOL)animated;
- (void)setTargetRect:(CGRect)targetRect inView:(UIView *)targetView;
- (void)update;

@property (nonatomic, getter=isMenuVisible) BOOL menuVisible;
@property (copy) NSArray *menuItems;

@end
