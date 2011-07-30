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

#import "UIPanGestureRecognizer.h"
#import "UIGestureRecognizerSubclass.h"
#import "UITouch+UIPrivate.h"
#import "UIEvent.h"

static UITouch *PanTouch(NSSet *touches)
{
    for (UITouch *touch in touches) {
        if ([touch _gesture] == _UITouchGesturePan) {
            return touch;
        }
    }
    return nil;
}

@implementation UIPanGestureRecognizer
@synthesize maximumNumberOfTouches=_maximumNumberOfTouches, minimumNumberOfTouches=_minimumNumberOfTouches;

- (id)initWithTarget:(id)target action:(SEL)action
{
    if ((self=[super initWithTarget:target action:action])) {
        _minimumNumberOfTouches = 1;
        _maximumNumberOfTouches = NSUIntegerMax;
        _translation = CGPointZero;
        _velocity = CGPointZero;
    }
    return self;
}

- (CGPoint)translationInView:(UIView *)view
{
    return _translation;
}

- (void)setTranslation:(CGPoint)translation inView:(UIView *)view
{
    _velocity = CGPointZero;
    _translation = translation;
}

- (BOOL)_translate:(CGPoint)delta withEvent:(UIEvent *)event
{
    const NSTimeInterval timeDiff = event.timestamp - _lastMovementTime;

    if (!CGPointEqualToPoint(delta, CGPointZero) && timeDiff > 0) {
        _translation.x += delta.x;
        _translation.y += delta.y;
        _velocity.x = delta.x / timeDiff;
        _velocity.y = delta.y / timeDiff;
        _lastMovementTime = event.timestamp;
        return YES;
    } else {
        return NO;
    }
}

- (void)reset
{
    [super reset];
    _translation = CGPointZero;
    _velocity = CGPointZero;
}

- (CGPoint)velocityInView:(UIView *)view
{
    return _velocity;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = PanTouch([event touchesForGestureRecognizer:self]);

    if (self.state == UIGestureRecognizerStatePossible && touch) {
        [self setTranslation:[touch _delta] inView:touch.view];
        _lastMovementTime = event.timestamp;
        self.state = UIGestureRecognizerStateBegan;
    } else if (self.state == UIGestureRecognizerStateBegan || self.state == UIGestureRecognizerStateChanged) {
        if (touch) {
            if ([self _translate:[touch _delta] withEvent:event]) {
                self.state = UIGestureRecognizerStateChanged;
            }
        } else {
            self.state = UIGestureRecognizerStateCancelled;
        }
    } else {
        self.state = UIGestureRecognizerStateFailed;
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (self.state == UIGestureRecognizerStateBegan || self.state == UIGestureRecognizerStateChanged) {
        UITouch *touch = PanTouch([event touchesForGestureRecognizer:self]);

        if (touch) {
            [self _translate:[touch _delta] withEvent:event];
            self.state = UIGestureRecognizerStateEnded;
        } else {
            self.state = UIGestureRecognizerStateCancelled;
        }
    } else {
        self.state = UIGestureRecognizerStateFailed;
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.state = UIGestureRecognizerStateFailed;
}

@end
