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

#import "UIViewAnimationGroup.h"
#import <QuartzCore/QuartzCore.h>
#import "UIColor.h"
#import "UIApplication.h"

static NSMutableSet *runningAnimationGroups = nil;

static inline CAMediaTimingFunction *CAMediaTimingFunctionFromUIViewAnimationCurve(UIViewAnimationCurve curve)
{
    switch (curve) {
        case UIViewAnimationCurveEaseInOut:	return [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        case UIViewAnimationCurveEaseIn:	return [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
        case UIViewAnimationCurveEaseOut:	return [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
        case UIViewAnimationCurveLinear:	return [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    }
    return nil;
}

BOOL UIViewAnimationOptionIsSet(UIViewAnimationOptions options, UIViewAnimationOptions option)
{
    return ((options & option) == option);
}

static inline UIViewAnimationOptions UIViewAnimationOptionCurve(UIViewAnimationOptions options)
{
    return (options & (UIViewAnimationOptionCurveEaseInOut
                       | UIViewAnimationOptionCurveEaseIn
                       | UIViewAnimationOptionCurveEaseOut
                       | UIViewAnimationOptionCurveLinear));
}

static inline UIViewAnimationOptions UIViewAnimationOptionTransition(UIViewAnimationOptions options)
{
    return (options & (UIViewAnimationOptionTransitionNone
                       | UIViewAnimationOptionTransitionFlipFromLeft
                       | UIViewAnimationOptionTransitionFlipFromRight
                       | UIViewAnimationOptionTransitionCurlUp
                       | UIViewAnimationOptionTransitionCurlDown
                       | UIViewAnimationOptionTransitionCrossDissolve
                       | UIViewAnimationOptionTransitionFlipFromTop
                       | UIViewAnimationOptionTransitionFlipFromBottom));
}

@implementation UIViewAnimationGroup {
    NSUInteger _waitingAnimations;
    BOOL _didStart;
    CFTimeInterval _animationBeginTime;
    UIView *_transitionView;
    BOOL _transitionShouldCache;
    NSMutableSet *_animatingViews;
}

+ (void)initialize
{
    if (self == [UIViewAnimationGroup class]) {
        runningAnimationGroups = [NSMutableSet setWithCapacity:1];
    }
}

- (id)initWithAnimationOptions:(UIViewAnimationOptions)options
{
    if ((self=[super init])) {
        _waitingAnimations = 1;
        _animationBeginTime = CACurrentMediaTime();
        _animatingViews = [NSMutableSet setWithCapacity:2];
        
        self.duration = 0.2;
        
        self.repeatCount = UIViewAnimationOptionIsSet(options, UIViewAnimationOptionRepeat)? FLT_MAX : 0;
        self.allowUserInteraction = UIViewAnimationOptionIsSet(options, UIViewAnimationOptionAllowUserInteraction);
        self.repeatAutoreverses = UIViewAnimationOptionIsSet(options, UIViewAnimationOptionAutoreverse);
        self.beginsFromCurrentState = UIViewAnimationOptionIsSet(options, UIViewAnimationOptionBeginFromCurrentState);

        const UIViewAnimationOptions animationCurve = UIViewAnimationOptionCurve(options);
        if (animationCurve == UIViewAnimationOptionCurveEaseIn) {
            self.curve = UIViewAnimationCurveEaseIn;
        } else if (animationCurve == UIViewAnimationOptionCurveEaseOut) {
            self.curve = UIViewAnimationCurveEaseOut;
        } else if (animationCurve == UIViewAnimationOptionCurveLinear) {
            self.curve = UIViewAnimationCurveLinear;
        } else {
            self.curve = UIViewAnimationCurveEaseInOut;
        }
        
        const UIViewAnimationOptions animationTransition = UIViewAnimationOptionTransition(options);
        if (animationTransition == UIViewAnimationOptionTransitionFlipFromLeft) {
            self.transition = UIViewAnimationGroupTransitionFlipFromLeft;
        } else if (animationTransition == UIViewAnimationOptionTransitionFlipFromRight) {
            self.transition = UIViewAnimationGroupTransitionFlipFromRight;
        } else if (animationTransition == UIViewAnimationOptionTransitionCurlUp) {
            self.transition = UIViewAnimationGroupTransitionCurlUp;
        } else if (animationTransition == UIViewAnimationOptionTransitionCurlDown) {
            self.transition = UIViewAnimationGroupTransitionCurlDown;
        } else if (animationTransition == UIViewAnimationOptionTransitionCrossDissolve) {
            self.transition = UIViewAnimationGroupTransitionCrossDissolve;
        } else if (animationTransition == UIViewAnimationOptionTransitionFlipFromTop) {
            self.transition = UIViewAnimationGroupTransitionFlipFromTop;
        } else if (animationTransition == UIViewAnimationOptionTransitionFlipFromBottom) {
            self.transition = UIViewAnimationGroupTransitionFlipFromBottom;
        } else {
            self.transition = UIViewAnimationGroupTransitionNone;
        }
    }
    return self;
}

- (NSArray *)allAnimatingViews
{
    @synchronized(runningAnimationGroups) {
        return [_animatingViews allObjects];
    }
}

- (void)notifyAnimationsDidStartIfNeeded
{
    if (!_didStart) {
        _didStart = YES;
        
        @synchronized(runningAnimationGroups) {
            [runningAnimationGroups addObject:self];
        }

        if ([self.delegate respondsToSelector:self.willStartSelector]) {
            typedef void(*WillStartMethod)(id, SEL, NSString *, void *);
            WillStartMethod method = (WillStartMethod)[self.delegate methodForSelector:self.willStartSelector];
            method(self.delegate, self.willStartSelector, self.name, self.context);
        }
    }
}

- (void)notifyAnimationsDidStopIfNeededUsingStatus:(BOOL)animationsDidFinish
{
    if (_waitingAnimations == 0) {
        if ([self.delegate respondsToSelector:self.didStopSelector]) {
            NSNumber *finishedArgument = [NSNumber numberWithBool:animationsDidFinish];
            typedef void(*DidFinishMethod)(id, SEL, NSString *, NSNumber *, void *);
            DidFinishMethod method = (DidFinishMethod)[self.delegate methodForSelector:self.didStopSelector];
            method(self.delegate, self.didStopSelector, self.name, finishedArgument, self.context);
        }
        
        if (self.completionBlock) {
            self.completionBlock(animationsDidFinish);
        }

        @synchronized(runningAnimationGroups) {
            [_animatingViews removeAllObjects];
            [runningAnimationGroups removeObject:self];
        }
    }
}

- (void)animationDidStart:(CAAnimation *)theAnimation
{
    NSAssert([NSThread isMainThread], @"expecting this to be on the main thread");

    [self notifyAnimationsDidStartIfNeeded];
}

- (void)animationDidStop:(CAAnimation *)theAnimation finished:(BOOL)flag
{
    NSAssert([NSThread isMainThread], @"expecting this to be on the main thread");

    _waitingAnimations--;
    [self notifyAnimationsDidStopIfNeededUsingStatus:flag];
}

- (CAAnimation *)addAnimation:(CAAnimation *)animation
{
    animation.timingFunction = CAMediaTimingFunctionFromUIViewAnimationCurve(self.curve);
    animation.duration = self.duration;
    animation.beginTime = _animationBeginTime + self.delay;
    animation.repeatCount = self.repeatCount;
    animation.autoreverses = self.repeatAutoreverses;
    animation.fillMode = kCAFillModeBackwards;
    animation.delegate = self;
    animation.removedOnCompletion = YES;
    _waitingAnimations++;
    return animation;
}

- (id)actionForView:(UIView *)view forKey:(NSString *)keyPath
{
    @synchronized(runningAnimationGroups) {
        [_animatingViews addObject:view];
    }

    if (_transitionView && self.transition != UIViewAnimationGroupTransitionNone) {
        return nil;
    } else {
        CALayer *layer = view.layer;
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:keyPath];
        animation.fromValue = self.beginsFromCurrentState? [layer.presentationLayer valueForKey:keyPath] : [layer valueForKey:keyPath];
        return [self addAnimation:animation];
    }
}

- (void)setTransitionView:(UIView *)view shouldCache:(BOOL)cache;
{
    _transitionView = view;
    _transitionShouldCache = cache;
}

- (void)commit
{
    if (_transitionView && self.transition != UIViewAnimationGroupTransitionNone) {
        CATransition *trans = [CATransition animation];
        
        switch (self.transition) {
            case UIViewAnimationGroupTransitionFlipFromLeft:
                trans.type = kCATransitionPush;
                trans.subtype = kCATransitionFromLeft;
                break;
                
            case UIViewAnimationGroupTransitionFlipFromRight:
                trans.type = kCATransitionPush;
                trans.subtype = kCATransitionFromRight;
                break;
                
            case UIViewAnimationGroupTransitionFlipFromTop:
                trans.type = kCATransitionPush;
                trans.subtype = kCATransitionFromTop;
                break;
                
            case UIViewAnimationGroupTransitionFlipFromBottom:
                trans.type = kCATransitionPush;
                trans.subtype = kCATransitionFromBottom;
                break;

            case UIViewAnimationGroupTransitionCurlUp:
                trans.type = kCATransitionReveal;
                trans.subtype = kCATransitionFromTop;
                break;
                
            case UIViewAnimationGroupTransitionCurlDown:
                trans.type = kCATransitionReveal;
                trans.subtype = kCATransitionFromBottom;
                break;
                
            case UIViewAnimationGroupTransitionCrossDissolve:
            default:
                trans.type = kCATransitionFade;
                break;
        }
        
        [_animatingViews addObject:_transitionView];
        [_transitionView.layer addAnimation:[self addAnimation:trans] forKey:kCATransition];
    }
    
    _waitingAnimations--;
    [self notifyAnimationsDidStopIfNeededUsingStatus:YES];
}

@end
