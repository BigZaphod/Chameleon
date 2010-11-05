//  Created by Sean Heber on 8/11/10.
#import "UITouch.h"

@class UIView;

@interface UITouch (UIPrivate)
- (void)_setPhase:(UITouchPhase)phase screenLocation:(CGPoint)screenLocation tapCount:(NSUInteger)tapCount delta:(CGPoint)delta timestamp:(NSTimeInterval)timestamp;
- (void)_setView:(UIView *)view;
- (void)_setTouchPhaseCancelled;
- (CGPoint)_delta;
- (UIView *)_previousView;
@end
