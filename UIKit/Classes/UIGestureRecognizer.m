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

#import "UIGestureRecognizer.h"
#import "UIGestureRecognizerSubclass.h"
#import "UITouch+UIPrivate.h"
#import "UIAction.h"
#import "UIApplication.h"
#import "UITouchEvent.h"

@implementation UIGestureRecognizer {
    NSMutableArray *_registeredActions;
    NSMutableArray *_trackingTouches;
    __unsafe_unretained UIView *_view;
    
    struct {
        unsigned shouldBegin : 1;
        unsigned shouldReceiveTouch : 1;
        unsigned shouldRecognizeSimultaneouslyWithGestureRecognizer : 1;
    } _delegateHas;
}

- (id)initWithTarget:(id)target action:(SEL)action
{
    if ((self=[super init])) {
        _state = UIGestureRecognizerStatePossible;
        _cancelsTouchesInView = YES;
        _delaysTouchesBegan = NO;
        _delaysTouchesEnded = YES;
        _enabled = YES;

        _registeredActions = [[NSMutableArray alloc] initWithCapacity:1];
        _trackingTouches = [[NSMutableArray alloc] initWithCapacity:1];
        
        [self addTarget:target action:action];
    }
    return self;
}

- (void)_setView:(UIView *)v
{
    if (v != _view) {
        [self reset]; // not sure about this, but I think it makes sense
        _view = v;
    }
}

- (void)setDelegate:(id<UIGestureRecognizerDelegate>)aDelegate
{
    if (aDelegate != _delegate) {
        _delegate = aDelegate;
        _delegateHas.shouldBegin = [_delegate respondsToSelector:@selector(gestureRecognizerShouldBegin:)];
        _delegateHas.shouldReceiveTouch = [_delegate respondsToSelector:@selector(gestureRecognizer:shouldReceiveTouch:)];
        _delegateHas.shouldRecognizeSimultaneouslyWithGestureRecognizer = [_delegate respondsToSelector:@selector(gestureRecognizer:shouldRecognizeSimultaneouslyWithGestureRecognizer:)];
    }
}

- (void)addTarget:(id)target action:(SEL)action
{
    NSAssert(target != nil, @"target must not be nil");
    NSAssert(action != NULL, @"action must not be NULL");
    
    UIAction *actionRecord = [[UIAction alloc] init];
    actionRecord.target = target;
    actionRecord.action = action;
    [_registeredActions addObject:actionRecord];
}

- (void)removeTarget:(id)target action:(SEL)action
{
    UIAction *actionRecord = [[UIAction alloc] init];
    actionRecord.target = target;
    actionRecord.action = action;
    [_registeredActions removeObject:actionRecord];
}

- (void)requireGestureRecognizerToFail:(UIGestureRecognizer *)otherGestureRecognizer
{
}

- (NSUInteger)numberOfTouches
{
    return [_trackingTouches count];
}

- (CGPoint)locationInView:(UIView *)view
{
    // by default, this should compute the centroid of all the involved points
    // of course as of this writing, Chameleon only supports one point but at least
    // it may be semi-correct if that ever changes. :D YAY FOR COMPLEXITY!
    
    CGFloat x = 0;
    CGFloat y = 0;
    CGFloat k = 0;
    
    for (UITouch *touch in _trackingTouches) {
        const CGPoint p = [touch locationInView:view];
        x += p.x;
        y += p.y;
        k++;
    }
    
    if (k > 0) {
        return CGPointMake(x/k, y/k);
    } else {
        return CGPointZero;
    }
}

- (CGPoint)locationOfTouch:(NSUInteger)touchIndex inView:(UIView *)view
{
    return [[_trackingTouches objectAtIndex:touchIndex] locationInView:view];
}

- (void)setState:(UIGestureRecognizerState)state
{
    if (_delegateHas.shouldBegin && _state == UIGestureRecognizerStatePossible && (state == UIGestureRecognizerStateRecognized || state == UIGestureRecognizerStateBegan)) {
        if (![_delegate gestureRecognizerShouldBegin:self]) {
            state = UIGestureRecognizerStateFailed;
        }
    }
    
    // the docs didn't say explicitly if these state transitions were verified, but I suspect they are. if anything, a check like this
    // should help debug things. it also helps me better understand the whole thing, so it's not a total waste of time :)

    typedef struct { UIGestureRecognizerState fromState, toState; BOOL shouldNotify; } StateTransition;

    #define NumberOfStateTransitions 9
    static const StateTransition allowedTransitions[NumberOfStateTransitions] = {
        // discrete gestures
        {UIGestureRecognizerStatePossible,		UIGestureRecognizerStateRecognized,     YES},
        {UIGestureRecognizerStatePossible,		UIGestureRecognizerStateFailed,          NO},

        // continuous gestures
        {UIGestureRecognizerStatePossible,		UIGestureRecognizerStateBegan,          YES},
        {UIGestureRecognizerStateBegan,			UIGestureRecognizerStateChanged,        YES},
        {UIGestureRecognizerStateBegan,			UIGestureRecognizerStateCancelled,      YES},
        {UIGestureRecognizerStateBegan,			UIGestureRecognizerStateEnded,          YES},
        {UIGestureRecognizerStateChanged,		UIGestureRecognizerStateChanged,        YES},
        {UIGestureRecognizerStateChanged,		UIGestureRecognizerStateCancelled,      YES},
        {UIGestureRecognizerStateChanged,		UIGestureRecognizerStateEnded,          YES}
    };
    
    const StateTransition *transition = NULL;

    for (NSUInteger t=0; t<NumberOfStateTransitions; t++) {
        if (allowedTransitions[t].fromState == _state && allowedTransitions[t].toState == state) {
            transition = &allowedTransitions[t];
            break;
        }
    }

    NSAssert2((transition != NULL), @"invalid state transition from %ld to %ld", _state, state);

    if (transition) {
        _state = transition->toState;
        
        if (transition->shouldNotify) {
            for (UIAction *actionRecord in _registeredActions) {
                // docs mention that the action messages are sent on the next run loop, so we'll do that here.
                // note that this means that reset can't happen until the next run loop, either otherwise
                // the state property is going to be wrong when the action handler looks at it, so as a result
                // I'm also delaying the reset call (if necessary) below in -continueTrackingWithEvent:
                [actionRecord.target performSelector:actionRecord.action withObject:self afterDelay:0];
            }
        }
    }
}

- (void)reset
{
    // note - this is also supposed to ignore any currently tracked touches
    // the touches themselves may not have gone away, so we don't just remove them from tracking, I think,
    // but instead just mark them as ignored by this gesture until the touches eventually end themselves.
    // in any case, this isn't implemented right now because we only have a single touch and so far I
    // haven't needed it.
    
    _state = UIGestureRecognizerStatePossible;
}

- (BOOL)canPreventGestureRecognizer:(UIGestureRecognizer *)preventedGestureRecognizer
{
    return YES;
}

- (BOOL)canBePreventedByGestureRecognizer:(UIGestureRecognizer *)preventingGestureRecognizer
{
    return YES;
}

- (void)ignoreTouch:(UITouch *)touch forEvent:(UIEvent*)event
{
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
}

- (void)_beginTrackingTouch:(UITouch *)touch withEvent:(UITouchEvent *)event
{
    if (self.enabled) {
        if (!_delegateHas.shouldReceiveTouch || [_delegate gestureRecognizer:self shouldReceiveTouch:touch]) {
            [touch _addGestureRecognizer:self];
            [_trackingTouches addObject:touch];
        }
    }
}

- (void)_continueTrackingWithEvent:(UITouchEvent *)event
{
    NSMutableSet *began = [NSMutableSet new];
    NSMutableSet *moved = [NSMutableSet new];
    NSMutableSet *ended = [NSMutableSet new];
    NSMutableSet *cancelled = [NSMutableSet new];
    BOOL multitouchSequenceIsEnded = YES;
    
    for (UITouch *touch in _trackingTouches) {
        if (touch.phase == UITouchPhaseBegan) {
            multitouchSequenceIsEnded = NO;
            [began addObject:touch];
        } else if (touch.phase == UITouchPhaseMoved) {
            multitouchSequenceIsEnded = NO;
            [moved addObject:touch];
        } else if (touch.phase == UITouchPhaseStationary) {
            multitouchSequenceIsEnded = NO;
        } else if (touch.phase == UITouchPhaseEnded) {
            [ended addObject:touch];
        } else if (touch.phase == UITouchPhaseCancelled) {
            [cancelled addObject:touch];
        }
    }

    if (_state == UIGestureRecognizerStatePossible || _state == UIGestureRecognizerStateBegan || _state == UIGestureRecognizerStateChanged) {
        if ([began count]) {
            [self touchesBegan:began withEvent:event];
        }

        if ([moved count]) {
            [self touchesMoved:moved withEvent:event];
        }
        
        if ([ended count]) {
            [self touchesEnded:ended withEvent:event];
        }
        
        if ([cancelled count]) {
            [self touchesCancelled:cancelled withEvent:event];
        }
    }
    
    // if all the touches are ended or cancelled, then the multitouch sequence must be over - so we can reset
    // our state back to normal and clear all the tracked touches, etc. to get ready for a new touch sequence
    // in the future.
    // this also applies to the special discrete gesture events because those events are only sent once!
    if (multitouchSequenceIsEnded || event.isDiscreteGesture) {
        // see note above in -setState: about the delay here!
        [self performSelector:@selector(reset) withObject:nil afterDelay:0];
    }
}

- (void)_endTrackingTouch:(UITouch *)touch withEvent:(UITouchEvent *)event
{
    [touch _removeGestureRecognizer:self];
    [_trackingTouches removeObject:touch];
}

- (NSString *)description
{
    NSString *state = @"";
    switch (self.state) {
        case UIGestureRecognizerStatePossible:
            state = @"Possible";
            break;
        case UIGestureRecognizerStateBegan:
            state = @"Began";
            break;
        case UIGestureRecognizerStateChanged:
            state = @"Changed";
            break;
        case UIGestureRecognizerStateEnded:
            state = @"Ended";
            break;
        case UIGestureRecognizerStateCancelled:
            state = @"Cancelled";
            break;
        case UIGestureRecognizerStateFailed:
            state = @"Failed";
            break;
    }
    return [NSString stringWithFormat:@"<%@: %p; state = %@; view = %@>", [self className], self, state, self.view];
}

@end
