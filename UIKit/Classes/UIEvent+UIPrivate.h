//  Created by Sean Heber on 8/11/10.
#import "UIEvent.h"

@class NSEvent, UITouch;

@interface UIEvent (UIPrivate)
- (void)_setNSEvent:(NSEvent *)theEvent;
- (NSEvent *)_NSEvent;
- (void)_setTouch:(UITouch *)theTouch;
- (UITouch *)_touch;
@end
