//  Created by Sean Heber on 8/31/10.
#import <Foundation/Foundation.h>

@class UIView;

@interface UIMenuController : NSObject {
}

+ (UIMenuController *)sharedMenuController;

- (void)setMenuVisible:(BOOL)menuVisibleanimated:(BOOL)animated;
- (void)setTargetRect:(CGRect)targetRect inView:(UIView *)targetView;

@end
