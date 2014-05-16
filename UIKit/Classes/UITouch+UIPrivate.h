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

#import "UITouch.h"

@class UIGestureRecognizer;

@interface UITouch (UIPrivate)
@property (nonatomic, readwrite, assign) NSTimeInterval timestamp;      // defaults to now
@property (nonatomic, readwrite, assign) NSUInteger tapCount;           // defaults to 0
@property (nonatomic, readwrite, assign) UITouchPhase phase;            // defaults to UITouchPhaseBegan, if changed to UITouchPhaseStationary, also sets previous location to current value of locationInWindow
@property (nonatomic, readwrite, assign) UIView *view;                  // defaults to nil
@property (nonatomic, readwrite, assign) CGPoint locationOnScreen;      // if phase is UITouchPhaseBegan or UITouchPhaseStationary, also sets internal previous location to same value

@property (nonatomic, readwrite, assign) BOOL wasDeliveredToView;       // defaults to NO, used to keep things on the up and up with gesture recognizers that can delay and cancel touches (pure evil)
@property (nonatomic, readwrite, assign) BOOL wasCancelledInView;       // defaults to NO, used to keep things on the up and up with gesture recognizers that can delay and cancel touches (pure evil)
@property (nonatomic, readonly) NSTimeInterval beganPhaseTimestamp;     // when phase is UITouchPhaseBegan, changes to timestamp property also copied here
@property (nonatomic, readonly) CGPoint beganPhaseLocationOnScreen;     // when phase is UITouchPhaseBegan, changes to locationOnScreen property also copied here

- (void)_addGestureRecognizer:(UIGestureRecognizer *)recognizer;
- (void)_removeGestureRecognizer:(UIGestureRecognizer *)recognizer;
@end
