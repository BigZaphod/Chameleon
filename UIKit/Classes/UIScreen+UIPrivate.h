//  Created by Sean Heber on 8/11/10.
#import "UIScreen.h"

@interface UIScreen (UIPrivate)
- (void)_setNSView:(NSView *)theView;
- (NSView *)_NSView;
- (CALayer *)_layer;
- (BOOL)_hasResizeIndicator;
- (void)_setPopoverController:(UIPopoverController *)controller;
- (UIPopoverController *)_popoverController;
@end
