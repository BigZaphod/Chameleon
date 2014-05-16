/*
 * Copyright (c) 2013, The Iconfactory. All rights reserved.
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

#import "UIViewController.h"

@interface UIViewController (AppKitIntegration)
// the purpose of this is to more easily support menu actions so the responder chain isn't
// broken all the time and you don't have to add a bunch of -canBecomeFirstResponser and
// -becomeFirstResponder calls in your code just to be able to handle this situation. On OSX
// it's pretty normal to expect that where you click becomes a responder and gets focus, but
// iOS code doesn't typically have such a notion because being a first responder is almost
// always only used for text fields and such. so iOS code will typically resign the first
// responder and leave nothing in it's place, which is perfectly fine most of the time on iOS.
// however on OSX we want to be able to easily handle menu actions that might apply to a whole
// view or something and since Chameleon bridges the responder chains, this is generally easy
// except that there is almost never a first responder to start sending things to! so the idea
// here is that your custom UIViewController subclasses can override these and return whatever
// they want to help things along.

// since -defaultResponderChildViewController returns nil by default, you will have to manage
// this yourself everywhere along your view controller hierarchy which is sort of annoying, but
// we used a lot of custom child view controllers in our hierarchy, so it is easy to return
// the most logical "primary" child controller for the user at the time, if there is one, or
// nil if reciever is the most logical place to start. you do not need to recursively call
// -defaultResponderChildViewController, instead just return the best controller from the point
// of view of the receiver and Chameleon will walk down the resulting chain until it returns
// nil. when it eventually returns nil, the search stops and then the last receiver is sent
// -defaultResponder to ask for the responder it would like to use to start the chain. if that
// returns nil, then there is effectively no responder chain so the action just gets passed into
// AppKit's responder chain. if there is a responder, we try to deliver the action down the
// responder chain starting from the result of -defaultResponder. if that fails, we fall off the
// end and end up back on AppKit's chain.

// -defaultResponderChildViewController is first called on the keyWindow's -rootViewController,
// and only if that window doesn't already have an explicit firstResponder (such as if a control
// or something became first responder in the usual way). it then proceeds as described above
// looking for something to use as the start of a responder chain.

// returns nil by default
- (UIViewController *)defaultResponderChildViewController;

// returns nil by default
- (UIResponder *)defaultResponder;
@end
