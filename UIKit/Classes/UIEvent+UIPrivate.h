//  Created by Sean Heber on 1/13/11.
#import "UIEvent.h"

@interface UIEvent (UIPrivate)
- (id)initWithEventType:(UIEventType)type;
- (void)_setTouch:(UITouch *)touch;
- (void)_setTimestamp:(NSTimeInterval)timestamp;
- (void)_setUnhandledKeyPressEvent;
- (BOOL)_isUnhandledKeyPressEvent;
@end
