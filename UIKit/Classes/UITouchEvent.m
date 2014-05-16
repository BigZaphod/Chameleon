/*
 * Copyright (c) 2013, The Iconfactory. All rights reserved.
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

#import "UITouchEvent.h"
#import "UITouch.h"
#import "UIGestureRecognizer+UIPrivate.h"

@implementation UITouchEvent

- (id)initWithTouch:(UITouch *)touch
{
    if ((self=[super init])) {
        _touch = touch;
        _touchEventGesture = UITouchEventGestureNone;
    }
    return self;
}

- (NSTimeInterval)timestamp
{
    return _touch.timestamp;
}

- (NSSet *)allTouches
{
    return [NSSet setWithObject:_touch];
}

- (UIEventType)type
{
    return UIEventTypeTouches;
}

- (BOOL)isDiscreteGesture
{
    return (_touchEventGesture == UITouchEventGestureScrollWheel ||
            _touchEventGesture == UITouchEventGestureRightClick ||
            _touchEventGesture == UITouchEventGestureMouseMove ||
            _touchEventGesture == UITouchEventGestureMouseEntered ||
            _touchEventGesture == UITouchEventGestureMouseExited ||
            _touchEventGesture == UITouchEventGestureSwipe);
}

- (void)endTouchEvent
{
    for (UIGestureRecognizer *gesture in _touch.gestureRecognizers) {
        [gesture _endTrackingTouch:_touch withEvent:self];
    }
}

@end
