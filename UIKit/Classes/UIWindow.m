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

#import "UIWindow+UIPrivate.h"
#import "UIView+UIPrivate.h"
#import "UIScreen+UIPrivate.h"
#import "UIScreenAppKitIntegration.h"
#import "UIApplication.h"
#import "UITouch+UIPrivate.h"
#import "UIScreenMode.h"
#import "UIResponderAppKitIntegration.h"
#import "UIViewController.h"
#import "UIGestureRecognizer+UIPrivate.h"
#import "UITouchEvent.h"
#import "UIKitView.h"
#import <AppKit/NSCursor.h>
#import <QuartzCore/QuartzCore.h>

const UIWindowLevel UIWindowLevelNormal = 0;
const UIWindowLevel UIWindowLevelStatusBar = 1000;
const UIWindowLevel UIWindowLevelAlert = 2000;

NSString *const UIWindowDidBecomeVisibleNotification = @"UIWindowDidBecomeVisibleNotification";
NSString *const UIWindowDidBecomeHiddenNotification = @"UIWindowDidBecomeHiddenNotification";
NSString *const UIWindowDidBecomeKeyNotification = @"UIWindowDidBecomeKeyNotification";
NSString *const UIWindowDidResignKeyNotification = @"UIWindowDidResignKeyNotification";

NSString *const UIKeyboardWillShowNotification = @"UIKeyboardWillShowNotification";
NSString *const UIKeyboardDidShowNotification = @"UIKeyboardDidShowNotification";
NSString *const UIKeyboardWillHideNotification = @"UIKeyboardWillHideNotification";
NSString *const UIKeyboardDidHideNotification = @"UIKeyboardDidHideNotification";
NSString *const UIKeyboardWillChangeFrameNotification = @"UIKeyboardWillChangeFrameNotification";

NSString *const UIKeyboardFrameBeginUserInfoKey = @"UIKeyboardFrameBeginUserInfoKey";
NSString *const UIKeyboardFrameEndUserInfoKey = @"UIKeyboardFrameEndUserInfoKey";
NSString *const UIKeyboardAnimationDurationUserInfoKey = @"UIKeyboardAnimationDurationUserInfoKey";
NSString *const UIKeyboardAnimationCurveUserInfoKey = @"UIKeyboardAnimationCurveUserInfoKey";

// deprecated
NSString *const UIKeyboardCenterBeginUserInfoKey = @"UIKeyboardCenterBeginUserInfoKey";
NSString *const UIKeyboardCenterEndUserInfoKey = @"UIKeyboardCenterEndUserInfoKey";
NSString *const UIKeyboardBoundsUserInfoKey = @"UIKeyboardBoundsUserInfoKey";

@implementation UIWindow {
    __weak UIResponder *_firstResponder;
    NSUndoManager *_undoManager;
}

- (id)initWithFrame:(CGRect)theFrame
{
    if ((self=[super initWithFrame:theFrame])) {
        _undoManager = [[NSUndoManager alloc] init];
        [self _makeHidden];	// do this first because before the screen is set, it will prevent any visibility notifications from being sent.
        self.screen = [UIScreen mainScreen];
        self.opaque = NO;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_NSWindowDidBecomeKeyNotification:) name:NSWindowDidBecomeKeyNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_NSWindowDidResignKeyNotification:) name:NSWindowDidResignKeyNotification object:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self _makeHidden];	// I don't really like this here, but the real UIKit seems to do something like this on window destruction as it sends a notification and we also need to remove it from the app's list of windows
    
    // since UIView's dealloc is called after this one, it's hard ot say what might happen in there due to all of the subview removal stuff
    // so it's safer to make sure these things are nil now rather than potential garbage. I don't like how much work UIView's -dealloc is doing
    // but at the moment I don't see a good way around it...
    _screen = nil;
    _undoManager = nil;
    _rootViewController = nil;
    
}

- (UIResponder *)_firstResponder
{
    return _firstResponder;
}

- (void)_setFirstResponder:(UIResponder *)newFirstResponder
{
    _firstResponder = newFirstResponder;
}

- (NSUndoManager *)undoManager
{
    return _undoManager;
}

- (UIView *)superview
{
    return nil;		// lies!
}

- (void)removeFromSuperview
{
    // does nothing
}

- (UIWindow *)window
{
    return self;
}

- (UIResponder *)nextResponder
{
    return [UIApplication sharedApplication];
}

- (void)setRootViewController:(UIViewController *)rootViewController
{
    if (rootViewController != _rootViewController) {
        [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        
        const BOOL was = [UIView areAnimationsEnabled];
        [UIView setAnimationsEnabled:NO];
        _rootViewController = rootViewController;
        _rootViewController.view.frame = self.bounds;
        [self addSubview:_rootViewController.view];
        [self layoutIfNeeded];
        [UIView setAnimationsEnabled:was];
    }
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    _rootViewController.view.frame = self.bounds;
}

- (void)setScreen:(UIScreen *)theScreen
{
    if (theScreen != _screen) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIScreenModeDidChangeNotification object:_screen];
        
        const BOOL wasHidden = self.hidden;
        [self _makeHidden];

        [self.layer removeFromSuperlayer];
        _screen = theScreen;
        [[_screen _layer] addSublayer:self.layer];

        if (!wasHidden) {
            [self _makeVisible];
        }

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_screenModeChangedNotification:) name:UIScreenModeDidChangeNotification object:_screen];
    }
}

- (void)_screenModeChangedNotification:(NSNotification *)note
{
    UIScreenMode *previousMode = [[note userInfo] objectForKey:@"_previousMode"];
    UIScreenMode *newMode = _screen.currentMode;

    if (!CGSizeEqualToSize(previousMode.size,newMode.size)) {
        [self _superviewSizeDidChangeFrom:previousMode.size to:newMode.size];
    }
}

- (CGPoint)convertPoint:(CGPoint)toConvert toWindow:(UIWindow *)toWindow
{
    if (toWindow == self) {
        return toConvert;
    } else {
        // Convert to screen coordinates
        toConvert.x += self.frame.origin.x;
        toConvert.y += self.frame.origin.y;
        
        if (toWindow) {
            // Now convert the screen coords into the other screen's coordinate space
            toConvert = [self.screen convertPoint:toConvert toScreen:toWindow.screen];

            // And now convert it from the new screen's space into the window's space
            toConvert.x -= toWindow.frame.origin.x;
            toConvert.y -= toWindow.frame.origin.y;
        }
        
        return toConvert;
    }
}

- (CGPoint)convertPoint:(CGPoint)toConvert fromWindow:(UIWindow *)fromWindow
{
    if (fromWindow == self) {
        return toConvert;
    } else {
        if (fromWindow) {
            // Convert to screen coordinates
            toConvert.x += fromWindow.frame.origin.x;
            toConvert.y += fromWindow.frame.origin.y;
            
            // Change to this screen.
            toConvert = [self.screen convertPoint:toConvert fromScreen:fromWindow.screen];
        }
        
        // Convert to window coordinates
        toConvert.x -= self.frame.origin.x;
        toConvert.y -= self.frame.origin.y;

        return toConvert;
    }
}

- (CGRect)convertRect:(CGRect)toConvert fromWindow:(UIWindow *)fromWindow
{
    CGPoint convertedOrigin = [self convertPoint:toConvert.origin fromWindow:fromWindow];
    return CGRectMake(convertedOrigin.x, convertedOrigin.y, toConvert.size.width, toConvert.size.height);
}

- (CGRect)convertRect:(CGRect)toConvert toWindow:(UIWindow *)toWindow
{
    CGPoint convertedOrigin = [self convertPoint:toConvert.origin toWindow:toWindow];
    return CGRectMake(convertedOrigin.x, convertedOrigin.y, toConvert.size.width, toConvert.size.height);
}

- (void)makeKeyWindow
{
    if (!self.isKeyWindow && self.screen) {
        // this check is here because if the underlying screen's UIKitView is AppKit's keyWindow, then
        // we must resign it because UIKit thinks it's currently the key window, too, so we do that here.
        if ([self.screen.keyWindow isKeyWindow]) {
            [self.screen.keyWindow resignKeyWindow];
        }
        
        // now we set the screen's key window to ourself - note that this doesn't really make it the key
        // window yet from an external point of view...
        [self.screen _setKeyWindow:self];
        
        // if it turns out we're now the key window, it means this window is ultimately within a UIKitView
        // that's the current AppKit key window, too, so we make it so. if we are NOT the key window, we
        // need to try to tell AppKit to make the UIKitView we're on the key window. If that works out,
        // we will get a notification and -becomeKeyWindow will be called from there, so we don't have to
        // do anything else in here.
        if (self.isKeyWindow) {
            [self becomeKeyWindow];
        } else {
            [[self.screen.UIKitView window] makeFirstResponder:self.screen.UIKitView];
            [[self.screen.UIKitView window] makeKeyWindow];
        }
    }
}

- (BOOL)isKeyWindow
{
    // only return YES if we have a screen and our screen's UIKitView is on the AppKit key window
    
    if (self.screen.keyWindow == self) {
        return [[self.screen.UIKitView window] isKeyWindow];
    }

    return NO;
}

- (void)becomeKeyWindow
{
    if ([[self _firstResponder] respondsToSelector:@selector(becomeKeyWindow)]) {
        [(id)[self _firstResponder] becomeKeyWindow];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:UIWindowDidBecomeKeyNotification object:self];
}

- (void)resignKeyWindow
{
    if ([[self _firstResponder] respondsToSelector:@selector(resignKeyWindow)]) {
        [(id)[self _firstResponder] resignKeyWindow];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:UIWindowDidResignKeyNotification object:self];
}

- (void)_NSWindowDidBecomeKeyNotification:(NSNotification *)note
{
    NSWindow *nativeWindow = [note object];

    // when the underlying screen's NSWindow becomes key, we can use the keyWindow property the screen itself
    // to know if this UIWindow should become key again now or not. If things match up, we fire off -becomeKeyWindow
    // again to let the app know this happened. Normally iOS doesn't run into situations where the user can change
    // the key window out from under the app, so this is going to be somewhat unusual UIKit behavior...
    if ([[self.screen.UIKitView window] isEqual:nativeWindow]) {
        if (self.screen.keyWindow == self) {
            [self becomeKeyWindow];
        }
    }
}

- (void)_NSWindowDidResignKeyNotification:(NSNotification *)note
{
    NSWindow *nativeWindow = [note object];
    
    // if the resigned key window is the same window that hosts our underlying screen, then we need to resign
    // this UIWindow, too. note that it does NOT actually unset the keyWindow property for the UIScreen!
    // this is because if the user clicks back in the screen's window, we need a way to reconnect this UIWindow
    // as the key window, too, so that's how that is done.
    if ([[self.screen.UIKitView window] isEqual:nativeWindow]) {
        if (self.screen.keyWindow == self) {
            [self resignKeyWindow];
        }
    }
}

- (void)_makeHidden
{
    if (!self.hidden) {
        [super setHidden:YES];
        
        if (self.screen) {
            [self.screen _removeWindow:self];
            [[NSNotificationCenter defaultCenter] postNotificationName:UIWindowDidBecomeHiddenNotification object:self];
        }
    }
}

- (void)_makeVisible
{
    if (self.hidden) {
        [super setHidden:NO];

        if (self.screen) {
            [self.screen _addWindow:self];
            [[NSNotificationCenter defaultCenter] postNotificationName:UIWindowDidBecomeVisibleNotification object:self];
        }
    }
}

- (void)setHidden:(BOOL)hide
{
    if (hide) {
        [self _makeHidden];
    } else {
        [self _makeVisible];
    }
}

- (void)makeKeyAndVisible
{
    [self _makeVisible];
    [self makeKeyWindow];
}

- (void)setWindowLevel:(UIWindowLevel)level
{
    self.layer.zPosition = level;
}

- (UIWindowLevel)windowLevel
{
    return self.layer.zPosition;
}

- (void)sendEvent:(UIEvent *)event
{
    if ([event isKindOfClass:[UITouchEvent class]]) {
        [self _processTouchEvent:(UITouchEvent *)event];
    }
}

- (void)_processTouchEvent:(UITouchEvent *)event
{
    // we only support a single touch, so there is a *lot* in here that would break or need serious changes
    // to properly support mulitouch. I still don't really like how all this works - especially with the
    // gesture recognizers, but I've been struggling to come up with a better way for far too long and just
    // have to deal with what I've got now.
    
    // if there's no touch for this window, return immediately
    if (event.touch.window != self) {
        return;
    }
    
    // normally there'd be no need to retain the view here, but this works around a strange problem I ran into.
    // what can happen is, now that UIView's -removeFromSuperview will remove the view from the active touch
    // instead of just cancel the touch (which is how I had implemented it previously - which was wrong), the
    // situation can arise where, in response to a touch event of some kind, the view may remove itself from its
    // superview in some fashion, which means that the handling of the touchesEnded:withEvent: (or whatever)
    // methods could somehow result in the view itself being destroyed before the method is even finished running!
    // a strong reference here works around this problem since the view is kept alive until we're done with it.
    // If someone can figure out some other, better way to fix this without it having to have this hacky-feeling
    // stuff here, that'd be cool, but be aware that this is here for a reason and that the problem it prevents is
    // somewhat contrived but not uncommon.
    UIView *view = event.touch.view;

    // first deliver new touches to all possible gesture recognizers
    if (event.touch.phase == UITouchPhaseBegan) {
        for (UIView *subview = view; subview != nil; subview = [subview superview]) {
            for (UIGestureRecognizer *gesture in subview.gestureRecognizers) {
                [gesture _beginTrackingTouch:event.touch withEvent:event];
            }
        }
    }

    BOOL gestureRecognized = NO;
    BOOL possibleGestures = NO;
    BOOL delaysTouchesBegan = NO;
    BOOL delaysTouchesEnded = NO;
    BOOL cancelsTouches = NO;

    // then allow all tracking gesture recognizers to have their way with the touches in this event before
    // anything else is done.
    for (UIGestureRecognizer *gesture in event.touch.gestureRecognizers) {
        [gesture _continueTrackingWithEvent:event];
        
        const BOOL recognized = (gesture.state == UIGestureRecognizerStateRecognized || gesture.state == UIGestureRecognizerStateBegan);
        const BOOL possible = (gesture.state == UIGestureRecognizerStatePossible);
        
        gestureRecognized |= recognized;
        possibleGestures |= possible;
        
        if (recognized || possible) {
            delaysTouchesBegan |= gesture.delaysTouchesBegan;
            
            // special case for scroll views so that -delaysContentTouches works somewhat as expected
            // likely this is pretty wrong, but it should work well enough for most normal cases, I suspect.
            if ([gesture.view isKindOfClass:[UIScrollView class]]) {
                UIScrollView *scrollView = (UIScrollView *)gesture.view;
                
                if ([gesture isEqual:scrollView.panGestureRecognizer] || [gesture isEqual:scrollView.scrollWheelGestureRecognizer]) {
                    delaysTouchesBegan |= scrollView.delaysContentTouches;
                }
            }
        }
        
        if (recognized) {
            delaysTouchesEnded |= gesture.delaysTouchesEnded;
            cancelsTouches |= gesture.cancelsTouchesInView;
        }
    }
    
    if (event.isDiscreteGesture) {
        // this should prevent delivery of the "touches" down the responder chain in roughly the same way a normal non-
        // discrete gesture would based on the settings of the in-play gesture recognizers.
        if (!gestureRecognized || (gestureRecognized && !cancelsTouches && !delaysTouchesBegan)) {
            if (event.touchEventGesture == UITouchEventGestureRightClick) {
                [view rightClick:event.touch withEvent:event];
            } else if (event.touchEventGesture == UITouchEventGestureScrollWheel) {
                [view scrollWheelMoved:event.translation withEvent:event];
            } else if (event.touchEventGesture == UITouchEventGestureMouseMove) {
                [view mouseMoved:event.touch withEvent:event];
            } else if (event.touchEventGesture == UITouchEventGestureMouseEntered) {
                [view mouseEntered:event.touch.view withEvent:event];
            } else if (event.touchEventGesture == UITouchEventGestureMouseExited) {
                [view mouseExited:event.touch.view withEvent:event];
            }
        }
    } else {
        if (event.touch.phase == UITouchPhaseBegan) {
            if ((!gestureRecognized && !possibleGestures) || !delaysTouchesBegan) {
                [view touchesBegan:event.allTouches withEvent:event];
                event.touch.wasDeliveredToView = YES;
            }
        } else if (delaysTouchesBegan && gestureRecognized && !event.touch.wasDeliveredToView) {
            // if we were delaying touches began and a gesture gets recognized, and we never sent it to the view,
            // we need to throw it away and be sure we never send it to the view for the duration of the gesture
            // so we do this by marking it both delivered and cancelled without actually sending it to the view.
            event.touch.wasDeliveredToView = YES;
            event.touch.wasCancelledInView = YES;
        } else if (delaysTouchesBegan && !gestureRecognized && !possibleGestures && !event.touch.wasDeliveredToView && event.touch.phase != UITouchPhaseCancelled) {
            // need to fake-send a touches began using the cached time and location in the touch
            // a followup move or ended or cancelled touch will be sent below if necessary
            const NSTimeInterval currentTimestamp = event.touch.timestamp;
            const UITouchPhase currentPhase = event.touch.phase;
            const CGPoint currentLocation = event.touch.locationOnScreen;
            
            event.touch.timestamp = event.touch.beganPhaseTimestamp;
            event.touch.locationOnScreen = event.touch.beganPhaseLocationOnScreen;
            event.touch.phase = UITouchPhaseBegan;
            
            [view touchesBegan:event.allTouches withEvent:event];
            event.touch.wasDeliveredToView = YES;
            
            event.touch.phase = currentPhase;
            event.touch.locationOnScreen = currentLocation;
            event.touch.timestamp = currentTimestamp;
        }
        
        if (event.touch.phase != UITouchPhaseBegan && event.touch.wasDeliveredToView && !event.touch.wasCancelledInView) {
            if (event.touch.phase == UITouchPhaseCancelled) {
                [view touchesCancelled:event.allTouches withEvent:event];
                event.touch.wasCancelledInView = YES;
            } else if (gestureRecognized && (cancelsTouches || (event.touch.phase == UITouchPhaseEnded && delaysTouchesEnded))) {
                // since we're supposed to cancel touches, mark it cancelled, send it to the view, and
                // then change it back to whatever it was because there might be other gesture recognizers
                // that are still using the touch for whatever reason and aren't going to expect it suddenly
                // cancelled. (technically cancelled touches are, I think, meant to be a last resort..
                // the sort of thing that happens when a phone call comes in or a modal window comes up)
                const UITouchPhase currentPhase = event.touch.phase;
                
                event.touch.phase = UITouchPhaseCancelled;
                
                [view touchesCancelled:event.allTouches withEvent:event];
                event.touch.wasCancelledInView = YES;
                
                event.touch.phase = currentPhase;
            } else if (event.touch.phase == UITouchPhaseMoved) {
                [view touchesMoved:event.allTouches withEvent:event];
            } else if (event.touch.phase == UITouchPhaseEnded) {
                [view touchesEnded:event.allTouches withEvent:event];
            }
        }
    }
    
    NSCursor *newCursor = [view mouseCursorForEvent:event] ?: [NSCursor arrowCursor];
    
    if ([NSCursor currentCursor] != newCursor) {
        [newCursor set];
    }
}

@end
