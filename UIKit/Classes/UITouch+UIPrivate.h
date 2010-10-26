//  Created by Sean Heber on 8/11/10.
#import "UITouch.h"

@class NSEvent;

@interface UITouch (UIPrivate)
- (void)_updateWithNSEvent:(NSEvent *)theEvent screenLocation:(CGPoint)baseLocation;
- (void)_setView:(UIView *)theView;
- (void)_cancel;
@end
