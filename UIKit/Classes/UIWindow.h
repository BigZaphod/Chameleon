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

typedef CGFloat UIWindowLevel;
extern const UIWindowLevel UIWindowLevelNormal;
extern const UIWindowLevel UIWindowLevelStatusBar;
extern const UIWindowLevel UIWindowLevelAlert;

extern NSString *const UIWindowDidBecomeVisibleNotification;
extern NSString *const UIWindowDidBecomeHiddenNotification;
extern NSString *const UIWindowDidBecomeKeyNotification;
extern NSString *const UIWindowDidResignKeyNotification;

extern NSString *const UIKeyboardWillShowNotification;
extern NSString *const UIKeyboardDidShowNotification;
extern NSString *const UIKeyboardWillHideNotification;
extern NSString *const UIKeyboardDidHideNotification;
extern NSString *const UIKeyboardWillChangeFrameNotification;

extern NSString *const UIKeyboardFrameBeginUserInfoKey;
extern NSString *const UIKeyboardFrameEndUserInfoKey;
extern NSString *const UIKeyboardAnimationDurationUserInfoKey;
extern NSString *const UIKeyboardAnimationCurveUserInfoKey;

// deprecated
extern NSString *const UIKeyboardCenterBeginUserInfoKey;
extern NSString *const UIKeyboardCenterEndUserInfoKey;
extern NSString *const UIKeyboardBoundsUserInfoKey;

@class UIScreen, UIViewController;

@interface UIWindow : UIView
- (CGPoint)convertPoint:(CGPoint)toConvert toWindow:(UIWindow *)toWindow;
- (CGPoint)convertPoint:(CGPoint)toConvert fromWindow:(UIWindow *)fromWindow;
- (CGRect)convertRect:(CGRect)toConvert fromWindow:(UIWindow *)fromWindow;
- (CGRect)convertRect:(CGRect)toConvert toWindow:(UIWindow *)toWindow;

- (void)makeKeyWindow;
- (void)makeKeyAndVisible;

- (void)resignKeyWindow;
- (void)becomeKeyWindow;

- (void)sendEvent:(UIEvent *)event;

// this property returns YES only if the underlying screen's UIKitView is on the AppKit's key window
// and this UIWindow was made key at some point in the past (and is still key from the point of view
// of the underlying screen) which is of course rather different from the real UIKit.
// this is done because unlike iOS, on OSX the user can change the key window at will at any time and
// we need a way to reconnect key windows when they change. :/
@property (nonatomic, readonly, getter=isKeyWindow) BOOL keyWindow;

@property (nonatomic, strong) UIScreen *screen;
@property (nonatomic, assign) UIWindowLevel windowLevel;
@property (nonatomic, strong) UIViewController *rootViewController;
@end
