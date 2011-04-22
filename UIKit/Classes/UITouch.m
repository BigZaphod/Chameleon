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

#import "UITouch+UIPrivate.h"
#import "UIWindow.h"
#import <Cocoa/Cocoa.h>

@implementation UITouch
@synthesize timestamp=_timestamp, tapCount=_tapCount, phase=_phase, view=_view, window=_window, gestureRecognizers=_gestureRecognizers;

- (id)init
{
    if ((self=[super init])) {
        _phase = UITouchPhaseCancelled;
    }
    return self;
}

- (void)dealloc
{
    [_window release];
    [_view release];
    [_gestureRecognizers release];
    [super dealloc];
}

- (void)_setPhase:(UITouchPhase)phase screenLocation:(CGPoint)screenLocation tapCount:(NSUInteger)tapCount delta:(CGPoint)delta timestamp:(NSTimeInterval)timestamp
{
    BOOL locationChanged = NO;
    
    if (!CGPointEqualToPoint(screenLocation, _location)) {
        _previousLocation = _location;
        _location = screenLocation;
        locationChanged = YES;
    }

    if (phase != _phase || locationChanged || tapCount != _tapCount || !CGPointEqualToPoint(_delta,delta)) {
        _timestamp = timestamp;
        _phase = phase;
        _tapCount = tapCount;
        _delta = delta;
    }
}

- (void)_setView:(UIView *)view
{
    if (_view != view) {
        [_view release];
        [_window release];
        _view = [view retain];
        _window = [view.window retain];
    }
}

- (void)_setTouchPhaseCancelled
{
    _phase = UITouchPhaseCancelled;
}

- (CGPoint)_delta
{
    return _delta;
}

- (UIWindow *)window
{
    return _window;
}

- (CGPoint)_convertLocationPoint:(CGPoint)thePoint toView:(UIView *)inView
{
    UIWindow *window = self.window;
    
    // The stored location should always be in the coordinate space of the UIScreen that contains the touch's window.
    // So first convert from the screen to the window:
    CGPoint point = [window convertPoint:thePoint fromWindow:nil];
    
    // Then convert to the desired location (if any).
    if (inView) {
        point = [inView convertPoint:point fromView:window];
    }
    
    return point;
}

- (CGPoint)locationInView:(UIView *)inView
{
    return [self _convertLocationPoint:_location toView:inView];
}

- (CGPoint)previousLocationInView:(UIView *)inView
{
    return [self _convertLocationPoint:_previousLocation toView:inView];
}

- (NSString *)description
{
    NSString *phase = @"";
    switch (self.phase) {
        case UITouchPhaseBegan:
            phase = @"Began";
            break;
        case UITouchPhaseMoved:
            phase = @"Moved";
            break;
        case UITouchPhaseStationary:
            phase = @"Stationary";
            break;
        case UITouchPhaseEnded:
            phase = @"Ended";
            break;
        case UITouchPhaseCancelled:
            phase = @"Cancelled";
            break;
        case UITouchPhaseHovered:
            phase = @"Hovered";
            break;
        case UITouchPhaseScrolled:
            phase = @"Scrolled";
            break;
        case UITouchPhaseRightClicked:
            phase = @"Right-clicked";
            break;
    }
    return [NSString stringWithFormat:@"<%@: %p; timestamp = %e; tapCount = %d; phase = %@; view = %@; window = %@>", [self className], self, self.timestamp, self.tapCount, phase, self.view, self.window];
}

@end
