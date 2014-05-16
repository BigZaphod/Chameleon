/*
 * Copyright (c) 2011, The Iconfactory. All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 *
 * 2. Redistributions in binary form must reproduce the above copyright notice,
 *    this list of conditions and the following disclaimer in the documentation
 *    and/or other materials provided with the distribution.
 *
 * 3. Neither the name of The Iconfactory nor the names of its contributors may
 *    be used to endorse or promote products derived from this software without
 *    specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE ICONFACTORY BE LIABLE FOR ANY DIRECT,
 * INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
 * BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
 * LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
 * OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
 * ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import "UISwipeGestureRecognizer.h"
#import "UIGestureRecognizerSubclass.h"
#import "UITouchEvent.h"

@implementation UISwipeGestureRecognizer

- (id)initWithTarget:(id)target action:(SEL)action
{
    if ((self=[super initWithTarget:target action:action])) {
        _direction = UISwipeGestureRecognizerDirectionRight;
        _numberOfTouchesRequired = 1;
    }
    return self;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (self.state == UIGestureRecognizerStatePossible) {
        if ([event isKindOfClass:[UITouchEvent class]]) {
            UITouchEvent *touchEvent = (UITouchEvent *)event;
            
            if (touchEvent.touchEventGesture == UITouchEventGestureSwipe) {
                if (_direction == UISwipeGestureRecognizerDirectionLeft && touchEvent.translation.x > 0) {
                    self.state = UIGestureRecognizerStateRecognized;
                } else if (_direction == UISwipeGestureRecognizerDirectionRight && touchEvent.translation.x < 0) {
                    self.state = UIGestureRecognizerStateRecognized;
                } else if (_direction == UISwipeGestureRecognizerDirectionUp && touchEvent.translation.y > 0) {
                    self.state = UIGestureRecognizerStateRecognized;
                } else if (_direction == UISwipeGestureRecognizerDirectionDown && touchEvent.translation.y < 0) {
                    self.state = UIGestureRecognizerStateRecognized;
                } else {
                    self.state = UIGestureRecognizerStateFailed;
                }
            } else {
                self.state = UIGestureRecognizerStateFailed;
            }
        }
    }
}

@end
