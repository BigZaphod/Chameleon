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

#import "UIViewController.h"
#import "UIWindow+UIPrivate.h"
#import "UIView+UIPrivate.h"
#import "UIScreen+UIPrivate.h"
#import "UIScreenAppKitIntegration.h"
#import "UIApplication+UIPrivate.h"
#import "UIEvent.h"
#import "UITouch+UIPrivate.h"
#import "UIScreenMode.h"
#import "UIResponderAppKitIntegration.h"
#import "UIViewAppKitIntegration.h"
#import "UIKitView.h"
#import "UIViewController.h"
#import "UIGestureRecognizerSubclass.h"
#import "UIGestureRecognizer+UIPrivate.h"
#import <AppKit/NSCursor.h>
#import <AppKit/NSHelpManager.h>
#import <AppKit/NSEvent.h>
#import <AppKit/NSWindow.h>
#import <AppKit/NSFont.h>
#import <AppKit/NSAttributedString.h>
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

NSString *const UIKeyboardFrameBeginUserInfoKey = @"UIKeyboardFrameBeginUserInfoKey";
NSString *const UIKeyboardFrameEndUserInfoKey = @"UIKeyboardFrameEndUserInfoKey";
NSString *const UIKeyboardAnimationDurationUserInfoKey = @"UIKeyboardAnimationDurationUserInfoKey";
NSString *const UIKeyboardAnimationCurveUserInfoKey = @"UIKeyboardAnimationCurveUserInfoKey";

// deprecated
NSString *const UIKeyboardCenterBeginUserInfoKey = @"UIKeyboardCenterBeginUserInfoKey";
NSString *const UIKeyboardCenterEndUserInfoKey = @"UIKeyboardCenterEndUserInfoKey";
NSString *const UIKeyboardBoundsUserInfoKey = @"UIKeyboardBoundsUserInfoKey";

@interface UIWindow ()
- (void)_showToolTipForView:(UIView *)view;
- (void)_hideCurrentToolTip;
- (void)_stopTrackingPotentiallyNewToolTip;
- (void)_toolTipViewDidChangeSuperview:(NSNotification *)notification;

@property (nonatomic, retain) UIView *currentToolTipView;
@property (nonatomic, retain) UIView *toolTipViewToShow;
@end


@implementation UIWindow {
    UIResponder *_firstResponder;
    NSUndoManager *_undoManager;
}
@synthesize screen = _screen;
@synthesize currentToolTipView = _currentToolTipView;
@synthesize toolTipViewToShow = _toolTipViewToShow;
@synthesize rootViewController = _rootViewController;

- (id)initWithFrame:(CGRect)theFrame
{
    if ((self=[super initWithFrame:theFrame])) {
        _undoManager = [[NSUndoManager alloc] init];
        [self _makeHidden];	// do this first because before the screen is set, it will prevent any visibility notifications from being sent.
        self.screen = [UIScreen mainScreen];
        self.opaque = NO;
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
	[self _stopTrackingPotentiallyNewToolTip];
	[self _hideCurrentToolTip];
    [self _makeHidden];	// I don't really like this here, but the real UIKit seems to do something like this on window destruction as it sends a notification and we also need to remove it from the app's list of windows
    [_screen release];
    [_undoManager release];
    [_rootViewController release];
    [super dealloc];
}

- (void)setRootViewController:(UIViewController *)rootViewController
{
	if (rootViewController != _rootViewController) {
        [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        [_rootViewController release];
        _rootViewController = [rootViewController retain];
        _rootViewController.view.frame = self.bounds;    // unsure about this
        [self addSubview:_rootViewController.view];
	}
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

- (void)setScreen:(UIScreen *)theScreen
{
    if (theScreen != _screen) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIScreenModeDidChangeNotification object:_screen];
        
        const BOOL wasHidden = self.hidden;
        [self _makeHidden];

        [self.layer removeFromSuperlayer];
        [_screen release];
        _screen = [theScreen retain];
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

- (void)becomeKeyWindow
{
    if ([[self _firstResponder] respondsToSelector:@selector(becomeKeyWindow)]) {
        [(id)[self _firstResponder] becomeKeyWindow];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:UIWindowDidBecomeKeyNotification object:self];
}

- (void)makeKeyWindow
{
    if (!self.isKeyWindow) {
        [[UIApplication sharedApplication].keyWindow resignKeyWindow];
        [[UIApplication sharedApplication] _setKeyWindow:self];
        [self becomeKeyWindow];
    }
}

- (BOOL)isKeyWindow
{
    return ([UIApplication sharedApplication].keyWindow == self);
}

- (void)resignKeyWindow
{
    if ([[self _firstResponder] respondsToSelector:@selector(resignKeyWindow)]) {
        [(id)[self _firstResponder] resignKeyWindow];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:UIWindowDidResignKeyNotification object:self];
}

- (void)_makeHidden
{
    if (!self.hidden) {
        [super setHidden:YES];
        if (self.screen) {
            [[UIApplication sharedApplication] _windowDidBecomeHidden:self];
            [[NSNotificationCenter defaultCenter] postNotificationName:UIWindowDidBecomeHiddenNotification object:self];
        }
    }
}

- (void)_makeVisible
{
    if (self.hidden) {
        [super setHidden:NO];
        if (self.screen) {
            [[UIApplication sharedApplication] _windowDidBecomeVisible:self];
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
    if (event.type == UIEventTypeTouches) {
        NSSet *touches = [event touchesForWindow:self];
        NSMutableSet *gestureRecognizers = [NSMutableSet setWithCapacity:0];

        for (UITouch *touch in touches) {
            [gestureRecognizers addObjectsFromArray:touch.gestureRecognizers];
        }

        for (UIGestureRecognizer *recognizer in gestureRecognizers) {
            [recognizer _recognizeTouches:touches withEvent:event];
        }

        for (UITouch *touch in touches) {
            if (touch.phase == UITouchPhaseBegan) {
                [touch.view touchesBegan:touches withEvent:event];
            } else if (touch.phase == UITouchPhaseMoved) {
                [touch.view touchesMoved:touches withEvent:event];
            } else if (touch.phase == UITouchPhaseEnded) {
                [touch.view touchesEnded:touches withEvent:event];
            } else if (touch.phase == UITouchPhaseCancelled) {
                [touch.view touchesCancelled:touches withEvent:event];
            } else if (touch.phase == _UITouchPhaseDiscreteGesture && [touch _gesture] == _UITouchDiscreteGestureMouseMove) {
                if ([touch.view hitTest:[touch locationInView:touch.view] withEvent:event]) {
                    [touch.view mouseMoved:[touch _delta] withEvent:event];
                }
            } else if (touch.phase == _UITouchPhaseDiscreteGesture && [touch _gesture] == _UITouchDiscreteGestureRightClick) {
                [touch.view rightClick:touch withEvent:event];
            } else if ((touch.phase == _UITouchPhaseDiscreteGesture && [touch _gesture] == _UITouchDiscreteGestureScrollWheel) ||
                       (touch.phase == _UITouchPhaseGestureChanged && [touch _gesture] == _UITouchGesturePan)) {
                [touch.view scrollWheelMoved:[touch _delta] withEvent:event];
            }
            
            NSCursor *newCursor = [touch.view mouseCursorForEvent:event] ?: [NSCursor arrowCursor];

            if ([NSCursor currentCursor] != newCursor) {
                [newCursor set];
            }
			
			if(touch.view != self.toolTipViewToShow) {
				[self _stopTrackingPotentiallyNewToolTip];
			}
			
			if(touch.view != _currentToolTipView) {
				if(touch.view.toolTip.length > 0) {
					// when your mouse moves from one view showing a tooltip to another, the new tooltip shows instantly instead of doing the normal delay
					if(_currentToolTipView != nil) {
						[self _hideCurrentToolTip];
						[self _showToolTipForView:touch.view];
					} else {
						self.toolTipViewToShow = touch.view;
						[self performSelector:@selector(_showToolTipForView:) withObject:_toolTipViewToShow afterDelay:3];
					}
				} else {
					[self _hideCurrentToolTip];
				}
			}
        }
		
		if(touches.count < 1) {
			[self _stopTrackingPotentiallyNewToolTip];
			[self _hideCurrentToolTip];
		}
    } else {
		[self _stopTrackingPotentiallyNewToolTip];
		[self _hideCurrentToolTip];
	}
}

- (void)mouseExitedView:(UIView *)exited enteredView:(UIView *)entered withEvent:(UIEvent *)event {	
	if(exited == nil || entered == nil) {
		[self _stopTrackingPotentiallyNewToolTip];
		[self _hideCurrentToolTip];
	}
	
	[super mouseExitedView:exited enteredView:entered withEvent:event];
}

- (void)_showToolTipForView:(UIView *)view {
	if(view == nil) return;
	
	NSMutableAttributedString *attributedToolTip = [[[NSMutableAttributedString alloc] initWithString:view.toolTip] autorelease];
	NSRange wholeStringRange = NSMakeRange(0, view.toolTip.length);
	[attributedToolTip addAttribute:NSFontAttributeName value:[NSFont systemFontOfSize:11.0f] range:wholeStringRange];
	
	NSMutableParagraphStyle *paragraphStyle = [[[NSMutableParagraphStyle alloc] init] autorelease];
	[paragraphStyle setAlignment:NSLeftTextAlignment];
	
	[attributedToolTip addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:wholeStringRange];
	
	[[NSHelpManager sharedHelpManager] setContextHelp:attributedToolTip forObject:view];
	[[NSHelpManager sharedHelpManager] showContextHelpForObject:view locationHint:[NSEvent mouseLocation]];
	self.currentToolTipView = view;
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_toolTipViewDidChangeSuperview:) name:UIViewDidMoveToSuperviewNotification object:self.currentToolTipView];
	
	self.toolTipViewToShow = nil;
}

- (void)_hideCurrentToolTip {	
	if(self.currentToolTipView == nil) return;
	
	[[NSNotificationCenter defaultCenter] removeObserver:self name:UIViewDidMoveToSuperviewNotification object:self.currentToolTipView];
	
	[[NSHelpManager sharedHelpManager] removeContextHelpForObject:self.currentToolTipView];
	
	// Post fake events to force the tooltip to hide. It doesn't fade away like standard tooltips do, but it's the only way I've found.
	NSEvent	*newEvent = [NSEvent mouseEventWithType:NSLeftMouseDown location:[NSEvent mouseLocation] modifierFlags:0 timestamp:0 windowNumber:[[self.screen.UIKitView window] windowNumber] context:[[self.screen.UIKitView window] graphicsContext] eventNumber:0 clickCount:1 pressure:0];
	[NSApp postEvent:newEvent atStart:NO];
	
	newEvent = [NSEvent mouseEventWithType:NSLeftMouseUp location:[NSEvent mouseLocation] modifierFlags:0 timestamp:0 windowNumber:[[self.screen.UIKitView window] windowNumber] context:[[self.screen.UIKitView window] graphicsContext] eventNumber:0 clickCount:1 pressure:0];
	[NSApp postEvent:newEvent atStart:NO];
	
	self.currentToolTipView = nil;
}

- (void)_stopTrackingPotentiallyNewToolTip {
	[[self class] cancelPreviousPerformRequestsWithTarget:self selector:@selector(_showToolTipForView:) object:self.toolTipViewToShow];
	self.toolTipViewToShow = nil;
}

- (void)_toolTipViewDidChangeSuperview:(NSNotification *)notification {
	if(self.currentToolTipView.window.screen.UIKitView.superview == nil || self.currentToolTipView.superview == nil) {
		[self _hideCurrentToolTip];
	}
}

@end
