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

#define SWIPE_MIN_DISTANCE 40
#define	SWIPE_MAX_ANGLE 30

@implementation UISwipeGestureRecognizer
@synthesize direction=_direction, numberOfTouchesRequired=_numberOfTouchesRequired;

static CGFloat _distance(CGPoint point1,CGPoint point2)
{
	CGFloat dx = point2.x - point1.x;
	CGFloat dy = point2.y - point1.y;
	return sqrt(dx*dx + dy*dy);
};

static CGFloat _angle(CGPoint start, CGPoint end)
{
	CGPoint origin = CGPointMake(end.x - start.x, end.y - start.y); // get origin point to origin by subtracting end from start
    CGFloat radians = atan2f(origin.y, origin.x); // get bearing in radians
    CGFloat degrees = radians * (180.0 / M_PI); // convert to degrees
    degrees = (degrees > 0.0 ? degrees : (360.0 + degrees)); // correct discontinuity
    return degrees;
}

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
	UITouch *touch = [touches anyObject];
	_beganLocation = [touch locationInView:self.view];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint movedLocation = [touch locationInView:self.view];
    CGFloat distance = _distance(_beganLocation, movedLocation);
    
    if (distance < SWIPE_MIN_DISTANCE) return;
    
    CGFloat angle = _angle(_beganLocation, movedLocation);
    int direction = -1;
    if (angle > 270 - SWIPE_MAX_ANGLE && angle < 270 + SWIPE_MAX_ANGLE) {
        direction = UISwipeGestureRecognizerDirectionUp;
    }
    if (angle > 180 - SWIPE_MAX_ANGLE && angle < 180 + SWIPE_MAX_ANGLE) {
        direction = UISwipeGestureRecognizerDirectionLeft;
    }
    if (angle > 90 - SWIPE_MAX_ANGLE && angle < 90 + SWIPE_MAX_ANGLE) {
        direction = UISwipeGestureRecognizerDirectionDown;
    }
    if ((angle > 360 - SWIPE_MAX_ANGLE && angle <= 360) || (angle >= 0 && angle <= SWIPE_MAX_ANGLE)) {
        direction = UISwipeGestureRecognizerDirectionRight;
    }
        
    if (direction == -1) {
      self.state = UIGestureRecognizerStateFailed;
    } else {
      self.state = self.direction == direction ? UIGestureRecognizerStateRecognized : UIGestureRecognizerStateFailed;
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    self.state = UIGestureRecognizerStateFailed;
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    self.state = UIGestureRecognizerStateFailed;
}

@end
