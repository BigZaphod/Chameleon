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

#import "UIView.h"

typedef NS_ENUM(NSInteger, UIViewAnimationGroupTransition) {
    UIViewAnimationGroupTransitionNone,
    UIViewAnimationGroupTransitionFlipFromLeft,
    UIViewAnimationGroupTransitionFlipFromRight,
    UIViewAnimationGroupTransitionCurlUp,
    UIViewAnimationGroupTransitionCurlDown,
    UIViewAnimationGroupTransitionFlipFromTop,
    UIViewAnimationGroupTransitionFlipFromBottom,
    UIViewAnimationGroupTransitionCrossDissolve,
};

extern BOOL UIViewAnimationOptionIsSet(UIViewAnimationOptions options, UIViewAnimationOptions option);

@interface UIViewAnimationGroup : NSObject

- (id)initWithAnimationOptions:(UIViewAnimationOptions)options;

- (id)actionForView:(UIView *)view forKey:(NSString *)keyPath;
- (void)setTransitionView:(UIView *)view shouldCache:(BOOL)cache;

- (NSArray *)allAnimatingViews;

@property (nonatomic, copy) NSString *name;
@property (nonatomic, assign) void *context;
@property (nonatomic, copy) void (^completionBlock)(BOOL finished);
@property (nonatomic, assign) BOOL allowUserInteraction;
@property (nonatomic, assign) BOOL beginsFromCurrentState;
@property (nonatomic, assign) UIViewAnimationCurve curve;
@property (nonatomic, assign) NSTimeInterval delay;
@property (nonatomic, strong) id delegate;
@property (nonatomic, assign) SEL didStopSelector;
@property (nonatomic, assign) SEL willStartSelector;
@property (nonatomic, assign) NSTimeInterval duration;
@property (nonatomic, assign) BOOL repeatAutoreverses;
@property (nonatomic, assign) float repeatCount;
@property (nonatomic, assign) UIViewAnimationGroupTransition transition;

- (void)commit;

@end
