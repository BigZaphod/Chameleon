//  Created by Sean Heber on 8/11/10.
#import "UIEvent.h"

@class NSEvent, UITouch, UIView;

@interface UIEvent (UIPrivate)
- (void)_setNSEvent:(NSEvent *)theEvent;
- (NSEvent *)_NSEvent;
- (void)_setTouch:(UITouch *)theTouch;
- (UITouch *)_touch;
- (UIView *)_previousMouseMovementView;
- (void)_setPreviousMouseMovementView:(UIView *)view;
- (UIEvent *)_cloneAndClearTouch;
@end
