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

@implementation UIGestureRecognizer
@synthesize delegate=_delegate, delaysTouchesBegan=_delaysTouchesBegan, delaysTouchesEnded=_delaysTouchesEnded, cancelsTouchesInView=_cancelsTouchesInView;
@synthesize state=_state, enabled=_enabled, view=_view;

- (id)initWithTarget:(id)target action:(SEL)action
{
    if ((self=[super init])) {
        _state = UIGestureRecognizerStatePossible;
        _cancelsTouchesInView = YES;
        _delaysTouchesBegan = NO;
        _delaysTouchesEnded = YES;
        _enabled = YES;

        [self addTarget:target action:action];
    }
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

- (void)_setView:(UIView *)v
{
    [self reset];	// not sure about this, but it kinda makes sense
    _view = v;
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
    NSAssert(target != nil, nil);
    NSAssert(action != NULL, nil);
}

- (void)removeTarget:(id)target action:(SEL)action
{
}

- (void)requireGestureRecognizerToFail:(UIGestureRecognizer *)otherGestureRecognizer
{
}

- (CGPoint)locationInView:(UIView *)view
{
    return CGPointZero;
}

- (void)setState:(UIGestureRecognizerState)state
{
    if (state != _state) {

        // the docs didn't say explicitly if these state transitions were verified, but I suspect they are. if anything, a check like this
        // should help debug things. it also helps me better understand the whole thing, so it's not a total waste of time :)

        typedef struct { UIGestureRecognizerState fromState, toState; } StateTransition;

        #define UIGestureRecognizerStateTransitions 12
        static const StateTransition allowedTransitions[UIGestureRecognizerStateTransitions] = {
            // discrete gestures
            {UIGestureRecognizerStatePossible,		UIGestureRecognizerStateRecognized},
            {UIGestureRecognizerStatePossible,		UIGestureRecognizerStateFailed},
            {UIGestureRecognizerStateFailed,		UIGestureRecognizerStatePossible},
            {UIGestureRecognizerStatePossible,		UIGestureRecognizerStateBegan},
            {UIGestureRecognizerStateRecognized,	UIGestureRecognizerStatePossible},
            // continuous gestures
            {UIGestureRecognizerStateBegan,			UIGestureRecognizerStateChanged},
            {UIGestureRecognizerStateBegan,			UIGestureRecognizerStateCancelled},
            {UIGestureRecognizerStateBegan,			UIGestureRecognizerStateEnded},
            {UIGestureRecognizerStateChanged,		UIGestureRecognizerStateCancelled},
            {UIGestureRecognizerStateChanged,		UIGestureRecognizerStateEnded},
            {UIGestureRecognizerStateCancelled,		UIGestureRecognizerStatePossible},
            {UIGestureRecognizerStateEnded,			UIGestureRecognizerStatePossible}
        };
        
        BOOL isValidStateTransition = NO;
        
        for (NSUInteger t=0; t<UIGestureRecognizerStateTransitions; t++) {
            if (allowedTransitions[t].fromState == _state && allowedTransitions[t].toState == state) {
                isValidStateTransition = YES;
                break;
            }
        }

        NSAssert(isValidStateTransition, nil);

        _state = state;
            
        // probably do stuff here like send messages if we're in the right state now.
    }
}

- (void)reset
{
}

- (BOOL)canPreventGestureRecognizer:(UIGestureRecognizer *)preventedGestureRecognizer
{
    return YES;
}

- (BOOL)canBePreventedByGestureRecognizer:(UIGestureRecognizer *)preventingGestureRecognizer
{
    return YES;
}

- (void)ignoreTouch:(UITouch*)touch forEvent:(UIEvent*)event
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
        case UIGestureRecognizerStateRecognized:
            state = @"Recognized";
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
