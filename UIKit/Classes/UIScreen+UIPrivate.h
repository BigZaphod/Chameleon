//  Created by Sean Heber on 8/11/10.
#import "UIScreen.h"

@class UIView, UIEvent;

@interface UIScreen (UIPrivate)
- (void)_setUIKitView:(UIKitView *)theView;
- (CALayer *)_layer;
- (BOOL)_hasResizeIndicator;
- (void)_setPopoverController:(UIPopoverController *)controller;
- (UIPopoverController *)_popoverController;
- (UIView *)_hitTest:(CGPoint)clickPoint event:(UIEvent *)theEvent;
@end
