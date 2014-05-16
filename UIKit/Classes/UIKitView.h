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

#import <Cocoa/Cocoa.h>
#import "UIApplicationDelegate.h"
#import "UIScreen.h"
#import "UIWindow.h"

@interface UIKitView : NSView

// returns the UIView (or nil) that successfully responds to a -hitTest:withEvent: at the given point.
// the point is specified in this view's coordinate system (unlike NSView's hitTest method).
- (UIView *)hitTestUIView:(NSPoint)point;

// this is an optional method
// it will set the sharedApplication's delegate to appDelegate. if delay is >0, it will then look in the app bundle for
// various default.png images (ideally it would replicate the search pattern that the iPad does, but for now it's just
// uses Default-Landscape.png). If delay <= 0, it skips doing any launch stuff and just calls the delegate's
// applicationDidFinishLaunching: method. It's up to the app delegate to create its own window, just as it is in the real
// UIKit when not using a XIB.
// ** IMPORTANT: appDelegate is *not* retained! **
- (void)launchApplicationWithDelegate:(id<UIApplicationDelegate>)appDelegate afterDelay:(NSTimeInterval)delay;

// these are sort of hacks used internally. I don't know if there's much need for them from the outside, really.
- (void)cancelTouchesInView:(UIView *)view;
- (void)sendStationaryTouches;

// this is an optional property to make it quick and easy to get a window to start adding views to.
// created on-demand to be the size of the UIScreen.bounds, flexible width/height, and calls makeKeyAndVisible when it is first created
@property (nonatomic, strong, readonly) UIWindow *UIWindow;

// a UIKitView owns a single UIScreen. when the UIKitView is part of an NSWindow hierarchy, the UIScreen appears as a connected screen in
// [UIScreen screens], etc.
@property (nonatomic, strong, readonly) UIScreen *UIScreen;
@end
