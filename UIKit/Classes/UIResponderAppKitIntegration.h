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

#import "UIResponder.h"

@class UIKey, UITouch;

@interface UIResponder (AppKitIntegration)
// Sent when the mouse scroll wheel changes.
- (void)scrollWheelMoved:(CGPoint)delta withEvent:(UIEvent *)event;

// Sent when the app gets a rightMouseDown-like event from OSX. There is no rightMouseDragged or rightMouseUp.
- (void)rightClick:(UITouch *)touch withEvent:(UIEvent *)event;

// These message are sent often, but only during hover mouse movements - not when clicking, click-dragging, in a gesture, etc.
// NOTE: You might get these messages more than once if you are capturing it in superview as messages are generated based on the subview
// that is hit. -mouseMoved:withEvent: may send you a touch that is outside of your view in some cases (such as when the mouse is leaving
// your view's bounds), however that behavior is not always reliable depending on arrangement of views or if the view is near the edge of
// the UIKitView's bounds, etc.
- (void)mouseEntered:(UIView *)view withEvent:(UIEvent *)event;
- (void)mouseMoved:(UITouch *)touch withEvent:(UIEvent *)event;
- (void)mouseExited:(UIView *)view withEvent:(UIEvent *)event;

// Return an NSCursor if you want to modify it or nil to use the default arrow. Follows responder chain.
- (id)mouseCursorForEvent:(UIEvent *)event;	// return an NSCursor if you want to modify it, return nil to use default

@end


@interface NSObject (UIResponderAppKitIntegrationKeyboardActions)
// This is triggered from AppKit's cancelOperation: so it should be sent in largely the same circumstances. Generally you can think of it as mapping
// to the ESC key, but CMD-. (period) also maps to it.
- (void)cancelOperation:(id)sender;

// This is mapped to CMD-Return and Enter and does not come from AppKit since it has no such convention as far as I've found. However it seemed like
// a useful thing to define, really, so that's what I'm doing. :)
- (void)commitOperation:(id)sender;
@end


