//  Created by Sean Heber on 8/31/10.
#import <Foundation/Foundation.h>

@class UIView;

@interface UIMenuController : NSObject {
	NSArray *_menuItems;
}

+ (UIMenuController *)sharedMenuController;

- (void)setMenuVisible:(BOOL)menuVisible animated:(BOOL)animated;
- (void)setTargetRect:(CGRect)targetRect inView:(UIView *)targetView;

@property (copy) NSArray *menuItems;

@end
