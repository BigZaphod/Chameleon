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
#import "UIView+UIPrivate.h"

@implementation UITouch {
    CGPoint _locationOnScreen;
    CGPoint _previousLocationOnScreen;
    NSMutableArray *_gestureRecognizers;
    BOOL _wasDeliveredToView;
    BOOL _wasCancelledInView;
    NSTimeInterval _beganPhaseTimestamp;
    CGPoint _beganPhaseLocationOnScreen;
}

- (id)init
{
    if ((self=[super init])) {
        _phase = UITouchPhaseBegan;
        _timestamp = [NSDate timeIntervalSinceReferenceDate];
        _gestureRecognizers = [NSMutableArray new];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_viewDidMoveToSuperviewNotification:) name:UIViewDidMoveToSuperviewNotification object:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIViewDidMoveToSuperviewNotification object:nil];
}

- (void)_viewDidMoveToSuperviewNotification:(NSNotification *)notification
{
    if ([_view isDescendantOfView:[notification object]]) {
        _view = nil;
    }
}

- (void)setTimestamp:(NSTimeInterval)timestamp
{
    _timestamp = timestamp;
    
    if (_phase == UITouchPhaseBegan) {
        _beganPhaseTimestamp = timestamp;
    }
}

- (void)setTapCount:(NSUInteger)tapCount
{
    _tapCount = tapCount;
}

- (void)setPhase:(UITouchPhase)phase
{
    _phase = phase;
    
    if (phase == UITouchPhaseStationary || phase == UITouchPhaseBegan) {
        _previousLocationOnScreen = _locationOnScreen;
    }
}

- (void)setView:(UIView *)view
{
    _view = view;
    _window = view.window;
}

- (CGPoint)locationOnScreen
{
    return _locationOnScreen;
}

- (void)setLocationOnScreen:(CGPoint)locationOnScreen
{
    _previousLocationOnScreen = _locationOnScreen;
    _locationOnScreen = locationOnScreen;

    if (_phase == UITouchPhaseStationary || _phase == UITouchPhaseBegan) {
        _previousLocationOnScreen = locationOnScreen;
    }
    
    if (_phase == UITouchPhaseBegan) {
        _beganPhaseLocationOnScreen = locationOnScreen;
    }
}

- (BOOL)wasDeliveredToView
{
    return _wasDeliveredToView;
}

- (void)setWasDeliveredToView:(BOOL)wasDeliveredToView
{
    _wasDeliveredToView = wasDeliveredToView;
}

- (BOOL)wasCancelledInView
{
    return _wasCancelledInView;
}

- (void)setWasCancelledInView:(BOOL)wasCancelledInView
{
    _wasCancelledInView = wasCancelledInView;
}

- (NSTimeInterval)beganPhaseTimestamp
{
    return _beganPhaseTimestamp;
}

- (CGPoint)beganPhaseLocationOnScreen
{
    return _beganPhaseLocationOnScreen;
}

- (NSArray *)gestureRecognizers
{
    return [_gestureRecognizers copy];
}

- (void)_addGestureRecognizer:(UIGestureRecognizer *)gesture
{
    [_gestureRecognizers addObject:gesture];
}

- (void)_removeGestureRecognizer:(UIGestureRecognizer *)gesture
{
    [_gestureRecognizers removeObject:gesture];
}

- (CGPoint)locationInView:(UIView *)inView
{
    return [self.window convertPoint:[self.window convertPoint:_locationOnScreen fromWindow:nil] toView:inView];
}

- (CGPoint)previousLocationInView:(UIView *)inView
{
    return [self.window convertPoint:[self.window convertPoint:_previousLocationOnScreen fromWindow:nil] toView:inView];
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
    }
    
    return [NSString stringWithFormat:@"<%@: %p; timestamp = %e; tapCount = %lu; phase = %@; view = %@; window = %@>", [self className], self, self.timestamp, (unsigned long)self.tapCount, phase, self.view, self.window];
}

@end
