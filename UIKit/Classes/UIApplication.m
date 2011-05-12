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

#import "UIApplication+UIPrivate.h"
#import "UIScreen+UIPrivate.h"
#import "UIScreenAppKitIntegration.h"
#import "UIKitView.h"
#import "UIEvent+UIPrivate.h"
#import "UITouch+UIPrivate.h"
#import "UIWindow+UIPrivate.h"
#import "UIPopoverController+UIPrivate.h"
#import "UIResponderAppKitIntegration.h"
#import "UIKey+UIPrivate.h"
#import <Cocoa/Cocoa.h>

NSString *const UIApplicationWillChangeStatusBarOrientationNotification = @"UIApplicationWillChangeStatusBarOrientationNotification";
NSString *const UIApplicationDidChangeStatusBarOrientationNotification = @"UIApplicationDidChangeStatusBarOrientationNotification";
NSString *const UIApplicationWillEnterForegroundNotification = @"UIApplicationWillEnterForegroundNotification";
NSString *const UIApplicationWillTerminateNotification = @"UIApplicationWillTerminateNotification";
NSString *const UIApplicationWillResignActiveNotification = @"UIApplicationWillResignActiveNotification";
NSString *const UIApplicationDidEnterBackgroundNotification = @"UIApplicationDidEnterBackgroundNotification";
NSString *const UIApplicationDidBecomeActiveNotification = @"UIApplicationDidBecomeActiveNotification";
NSString *const UIApplicationDidFinishLaunchingNotification = @"UIApplicationDidFinishLaunchingNotification";
NSString *const UIApplicationNetworkActivityIndicatorChangedNotification = @"UIApplicationNetworkActivityIndicatorChangedNotification";

NSString *const UIApplicationLaunchOptionsURLKey = @"UIApplicationLaunchOptionsURLKey";
NSString *const UIApplicationLaunchOptionsSourceApplicationKey = @"UIApplicationLaunchOptionsSourceApplicationKey";
NSString *const UIApplicationLaunchOptionsRemoteNotificationKey = @"UIApplicationLaunchOptionsRemoteNotificationKey";
NSString *const UIApplicationLaunchOptionsAnnotationKey = @"UIApplicationLaunchOptionsAnnotationKey";
NSString *const UIApplicationLaunchOptionsLocalNotificationKey = @"UIApplicationLaunchOptionsLocalNotificationKey";
NSString *const UIApplicationLaunchOptionsLocationKey = @"UIApplicationLaunchOptionsLocationKey";

NSString *const UIApplicationDidReceiveMemoryWarningNotification = @"UIApplicationDidReceiveMemoryWarningNotification";

NSString *const UITrackingRunLoopMode = @"UITrackingRunLoopMode";

UIBackgroundTaskIdentifier const UIBackgroundTaskInvalid = NSUIntegerMax; // correct?
NSTimeInterval const UIMinimumKeepAliveTimeout = 0;

static UIApplication *_theApplication = nil;

static CGPoint ScreenLocationFromNSEvent(UIScreen *theScreen, NSEvent *theNSEvent)
{
    CGPoint screenLocation = NSPointToCGPoint([[theScreen UIKitView] convertPoint:[theNSEvent locationInWindow] fromView:nil]);
    if (![[theScreen UIKitView] isFlipped]) {
        // the y coord from the NSView might be inverted
        screenLocation.y = theScreen.bounds.size.height - screenLocation.y - 1;
    }
    return screenLocation;
}

static CGPoint ScrollDeltaFromNSEvent(NSEvent *theNSEvent)
{
    double dx, dy;

    CGEventRef cgEvent = [theNSEvent CGEvent];
    const int64_t isContinious = CGEventGetIntegerValueField(cgEvent, kCGScrollWheelEventIsContinuous);
    
    if (isContinious == 0) {
        CGEventSourceRef source = CGEventCreateSourceFromEvent(cgEvent);
        double pixelsPerLine;
        
        if (source) {
           pixelsPerLine = CGEventSourceGetPixelsPerLine(source);
            CFRelease(source);
        } else {
            // docs often say things like, "the default is near 10" so it seems reasonable that if the source doesn't work
            // for some reason to fetch the pixels per line, then 10 is probably a decent fallback value. :)
            pixelsPerLine = 10;
        }

        dx = CGEventGetDoubleValueField(cgEvent, kCGScrollWheelEventFixedPtDeltaAxis2) * pixelsPerLine;
        dy = CGEventGetDoubleValueField(cgEvent, kCGScrollWheelEventFixedPtDeltaAxis1) * pixelsPerLine;
    } else {
        dx = CGEventGetIntegerValueField(cgEvent, kCGScrollWheelEventPointDeltaAxis2);
        dy = CGEventGetIntegerValueField(cgEvent, kCGScrollWheelEventPointDeltaAxis1);
    }

    return CGPointMake(-dx, -dy);
}

static BOOL TouchIsActive(UITouch *touch)
{
    return (touch.phase == UITouchPhaseBegan || touch.phase == UITouchPhaseMoved || touch.phase == UITouchPhaseStationary);
}

@implementation UIApplication
@synthesize keyWindow=_keyWindow, delegate=_delegate, idleTimerDisabled=_idleTimerDisabled, applicationSupportsShakeToEdit=_applicationSupportsShakeToEdit;
@synthesize applicationIconBadgeNumber = _applicationIconBadgeNumber;

+ (void)initialize
{
    if (self == [UIApplication class]) {
        _theApplication = [[UIApplication alloc] init];
    }
}

+ (UIApplication *)sharedApplication
{
    return _theApplication;
}

- (id)init
{
    if ((self=[super init])) {
        _currentEvent = [[UIEvent alloc] initWithEventType:UIEventTypeTouches];
        [_currentEvent _setTouch:[[[UITouch alloc] init] autorelease]];
        _visibleWindows = [[NSMutableSet alloc] init];
        _applicationSupportsShakeToEdit = YES;		// yeah... not *really* true, but UIKit defaults to YES :)
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_applicationWillTerminate:) name:NSApplicationWillTerminateNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_applicationWillResignActive:) name:NSApplicationWillResignActiveNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_applicationDidBecomeActive:) name:NSApplicationDidBecomeActiveNotification object:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [_currentEvent release];
    [_visibleWindows release];
    [super dealloc];
}

- (NSTimeInterval)statusBarOrientationAnimationDuration
{
    return 0.3;
}

- (BOOL)isStatusBarHidden
{
    return YES;
}

- (CGRect)statusBarFrame
{
    return CGRectZero;
}

- (UIApplicationState)applicationState
{
    return UIApplicationStateActive;
}

- (NSTimeInterval)backgroundTimeRemaining
{
    return 0;
}

- (BOOL)isNetworkActivityIndicatorVisible
{
    return _networkActivityIndicatorVisible;
}

- (void)setNetworkActivityIndicatorVisible:(BOOL)b
{
    if (b != [self isNetworkActivityIndicatorVisible]) {
        _networkActivityIndicatorVisible = b;
        [[NSNotificationCenter defaultCenter] postNotificationName:UIApplicationNetworkActivityIndicatorChangedNotification object:self];
    }
}

- (void)beginIgnoringInteractionEvents
{
    _ignoringInteractionEvents++;
}

- (void)endIgnoringInteractionEvents
{
    _ignoringInteractionEvents--;
}

- (BOOL)isIgnoringInteractionEvents
{
    return (_ignoringInteractionEvents > 0);
}

- (UIInterfaceOrientation)statusBarOrientation
{
    return UIInterfaceOrientationPortrait;
}

- (void)setStatusBarOrientation:(UIInterfaceOrientation)orientation
{
}

- (UIStatusBarStyle)statusBarStyle
{
    return UIStatusBarStyleDefault;
}

- (void)setStatusBarStyle:(UIStatusBarStyle)statusBarStyle
{
}

- (void)setStatusBarStyle:(UIStatusBarStyle)statusBarStyle animated:(BOOL)animated
{
}

- (void)presentLocalNotificationNow:(UILocalNotification *)notification
{
}

- (void)cancelAllLocalNotifications
{
}

- (void)cancelLocalNotification:(UILocalNotification *)notification
{
}

- (NSArray *)scheduledLocalNotifications
{
    return nil;
}

- (void)setScheduledLocalNotifications:(NSArray *)scheduledLocalNotifications
{
}

- (void)_setKeyWindow:(UIWindow *)newKeyWindow
{
    _keyWindow = newKeyWindow;

    if (_keyWindow) {
        // this will make the NSView that the key window lives on the first responder in its NSWindow
        // highly confusing, but I think this is mostly the correct thing to do
        // when a UIView is made first responder, it also tells its window to become the key window
        // which means that we can ultimately end up here and if keyboard stuff is to work as expected
        // (for example) the underlying NSView really needs to be the first responder as far as AppKit
        // is concerned. this is all very confusing in my mind right now, but I think it makes sense.
        [[[_keyWindow.screen UIKitView] window] makeFirstResponder:[_keyWindow.screen UIKitView]];
    }
}

- (void)_windowDidBecomeVisible:(UIWindow *)theWindow
{
    [_visibleWindows addObject:[NSValue valueWithNonretainedObject:theWindow]];
}

- (void)_windowDidBecomeHidden:(UIWindow *)theWindow
{
    if (theWindow == _keyWindow) [self _setKeyWindow:nil];
    [_visibleWindows removeObject:[NSValue valueWithNonretainedObject:theWindow]];
}

- (NSArray *)windows
{
    NSSortDescriptor *sort = [[[NSSortDescriptor alloc] initWithKey:@"windowLevel" ascending:YES] autorelease];
    return [[_visibleWindows valueForKey:@"nonretainedObjectValue"] sortedArrayUsingDescriptors:[NSArray arrayWithObject:sort]];
}

- (BOOL)sendAction:(SEL)action to:(id)target from:(id)sender forEvent:(UIEvent *)event
{
    if (!target) {
        // The docs say this method will start with the first responder if target==nil. Initially I thought this meant that there was always a given
        // or set first responder (attached to the window, probably). However it doesn't appear that is the case. Instead it seems UIKit is perfectly
        // happy to function without ever having any UIResponder having had a becomeFirstResponder sent to it. This method seems to work by starting
        // with sender and traveling down the responder chain from there if target==nil. The first object that responds to the given action is sent
        // the message. (or no one is)
        
        // My confusion comes from the fact that motion events and keyboard events are supposed to start with the first responder - but what is that
        // if none was ever set? Apparently the answer is, if none were set, the message doesn't get delivered. If you expicitly set a UIResponder
        // using becomeFirstResponder, then it will receive keyboard/motion events but it does not receive any other messages from other views that
        // happen to end up calling this method with a nil target. So that's a seperate mechanism and I think it's confused a bit in the docs.
        
        // It seems that the reality of message delivery to "first responder" is that it depends a bit on the source. If the source is an external
        // event like motion or keyboard, then there has to have been an explicitly set first responder (by way of becomeFirstResponder) in order for
        // those events to even get delivered at all. If there is no responder defined, the action is simply never sent and thus never received.
        // This is entirely independent of what "first responder" means in the context of a UIControl. Instead, for a UIControl, the first responder
        // is the first UIResponder (including the UIControl itself) that responds to the action. It starts with the UIControl (sender) and not with
        // whatever UIResponder may have been set with becomeFirstResponder.
        
        id responder = sender;
        while (responder) {
            if ([responder respondsToSelector:action]) {
                target = responder;
                break;
            } else if ([responder respondsToSelector:@selector(nextResponder)]) {
                responder = [responder nextResponder];
            } else {
                responder = nil;
            }
        }
    }
    
    if (target) {
        [target performSelector:action withObject:sender withObject:event];
        return YES;
    } else {
        return NO;
    }
}

- (UIResponder *)_firstResponderForScreen:(UIScreen *)screen
{
    if (_keyWindow.screen == screen) {
        return [_keyWindow _firstResponder];
    } else {
        return nil;
    }
}

- (BOOL)_sendActionToFirstResponder:(SEL)action withSender:(id)sender fromScreen:(UIScreen *)theScreen
{
    UIResponder *responder = [self _firstResponderForScreen:theScreen];
    
    while (responder) {
        if ([responder respondsToSelector:action]) {
            [responder performSelector:action withObject:sender];
            return YES;
        } else {
            responder = [responder nextResponder];
        }
    }
    
    return NO;
}

- (BOOL)_firstResponderCanPerformAction:(SEL)action withSender:(id)sender fromScreen:(UIScreen *)theScreen
{
    return [[self _firstResponderForScreen:theScreen] canPerformAction:action withSender:sender];
}

- (void)sendEvent:(UIEvent *)event
{
    for (UITouch *touch in [event allTouches]) {
        [touch.window sendEvent:event];
    }
}

- (BOOL)openURL:(NSURL *)url
{
    return [[NSWorkspace sharedWorkspace] openURL:url];
}

- (BOOL)canOpenURL:(NSURL *)url
{
    NSURL *appURL = [[NSWorkspace sharedWorkspace] URLForApplicationToOpenURL:url];
    return (appURL != nil);
}

- (BOOL)_sendGlobalKeyboardNSEvent:(NSEvent *)theNSEvent fromScreen:(UIScreen *)theScreen
{
    if (![self isIgnoringInteractionEvents]) {
        UIKey *key = [[[UIKey alloc] initWithNSEvent:theNSEvent] autorelease];
        
        if (key.type == UIKeyTypeEnter || (key.commandKeyPressed && key.type == UIKeyTypeReturn)) {
            if ([self _firstResponderCanPerformAction:@selector(commit:) withSender:key fromScreen:theScreen]) {
                return [self _sendActionToFirstResponder:@selector(commit:) withSender:key fromScreen:theScreen];
            }
        }
    }
    
    return NO;
}

- (BOOL)_sendKeyboardNSEvent:(NSEvent *)theNSEvent fromScreen:(UIScreen *)theScreen
{
    if (![self isIgnoringInteractionEvents]) {
        if (![self _sendGlobalKeyboardNSEvent:theNSEvent fromScreen:theScreen]) {
            UIResponder *firstResponder = [self _firstResponderForScreen:theScreen];
            
            if (firstResponder) {
                UIKey *key = [[[UIKey alloc] initWithNSEvent:theNSEvent] autorelease];
                UIEvent *event = [[[UIEvent alloc] initWithEventType:UIEventTypeKeyPress] autorelease];
                [event _setTimestamp:[theNSEvent timestamp]];
                
                [firstResponder keyPressed:key withEvent:event];
                return ![event _isUnhandledKeyPressEvent];
            }
        }
    }
    
    return NO;
}

- (void)_sendMouseNSEvent:(NSEvent *)theNSEvent fromScreen:(UIScreen *)theScreen
{
    UITouch *touch = [[_currentEvent allTouches] anyObject];
    BOOL isSupportedEvent = NO;
    
    [_currentEvent _setTimestamp:[theNSEvent timestamp]];
    
    const NSTimeInterval timestamp = [theNSEvent timestamp];
    const CGPoint screenLocation = ScreenLocationFromNSEvent(theScreen, theNSEvent);
    const CGPoint delta = ScrollDeltaFromNSEvent(theNSEvent);

    if (TouchIsActive(touch)) {
        isSupportedEvent = YES;
        
        switch ([theNSEvent type]) {
            case NSLeftMouseUp:
                [touch _setPhase:UITouchPhaseEnded screenLocation:screenLocation tapCount:touch.tapCount delta:delta timestamp:timestamp];
                break;
                
            case NSLeftMouseDragged:
                [touch _setPhase:UITouchPhaseMoved screenLocation:screenLocation tapCount:touch.tapCount delta:delta timestamp:timestamp];
                break;
                
            default:
                [touch _setPhase:UITouchPhaseStationary screenLocation:screenLocation tapCount:touch.tapCount delta:delta timestamp:timestamp];
                break;
        }
    } else if (![self isIgnoringInteractionEvents]) {
        switch ([theNSEvent type]) {
            case NSLeftMouseDown:
                isSupportedEvent = YES;
                [touch _setPhase:UITouchPhaseBegan screenLocation:screenLocation tapCount:[theNSEvent clickCount] delta:delta timestamp:timestamp];
                break;
                
            case NSScrollWheel:
                isSupportedEvent = YES;
                [touch _setPhase:UITouchPhaseScrolled screenLocation:screenLocation tapCount:0 delta:delta timestamp:timestamp];
                break;
                
            case NSMouseMoved:
            case NSMouseEntered:
            case NSMouseExited:
                isSupportedEvent = YES;
                [touch _setPhase:UITouchPhaseHovered screenLocation:screenLocation tapCount:0 delta:delta timestamp:timestamp];
                break;
                
            case NSRightMouseDown:
                isSupportedEvent = YES;
                [touch _setPhase:UITouchPhaseRightClicked screenLocation:screenLocation tapCount:1 delta:delta timestamp:timestamp];
                break;
        }
        
        // handle mouse enter/exit view changes as well as setting the new view for the touch
        if (isSupportedEvent) {
            UIView *previousView = [touch.view retain];
            [touch _setView:[theScreen _hitTest:screenLocation event:_currentEvent]];
            
            if (touch.view != previousView) {
                [previousView mouseExitedView:previousView enteredView:touch.view withEvent:_currentEvent];
                [touch.view mouseExitedView:previousView enteredView:touch.view withEvent:_currentEvent];
            }
            
            [previousView release];
        }
    }
    
    if (isSupportedEvent) {
        [self sendEvent:_currentEvent];
    }
}

// this is used to cause an interruption/cancel of the current touch.
// (1) if aView is nil, it sends a mouse exit event to the last touched view, and sends a touch cancelled event if there was an "active" touch.
// (2) if aView is NOT nil, no event is sent, but if the last touched view is a decendant of aView, the touch is marked cancelled.
// Use (1) is for when a modal UI element appears (such as a native popup menu), or when a UIPopoverController appears. It seems to make the most sense
// to call _cancelTouchesInView: *after* the modal menu has been dismissed, as this causes UI elements to remain in their "pushed" state while the menu
// is being displayed. If that behavior isn't desired, the simple solution is to present the menu from touchesEnded: instead of touchesBegan:.
// Use (2) is specifically for when a UIView is removed from its superview. This case aborts touch handling if the view being removed is a part of
// the currently active touch. The real UIKit also aborts an active touch in this situation and no cancel events are ever sent as far as I can tell - it
// just seems to abort the whole thing immediately. If the removed view has nothing to do with the current touch event, nothing happens.
- (void)_cancelTouchesInView:(UIView *)aView
{
    UITouch *touch = [[_currentEvent allTouches] anyObject];
    UIView *touchedView = touch.view;
    const BOOL shouldCancelTouch = (!aView || [touchedView isDescendantOfView:aView]);
    
    if (shouldCancelTouch) {
        const BOOL wasActiveTouch = TouchIsActive(touch);
        
        [touch _setTouchPhaseCancelled];
        
        if (!aView && wasActiveTouch) {
            [self sendEvent:_currentEvent];
        }
    }
}

- (void)_applicationWillTerminate:(NSNotification *)note
{
    if ([_delegate respondsToSelector:@selector(applicationWillTerminate:)]) {
        [_delegate applicationWillTerminate:self];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:UIApplicationWillTerminateNotification object:self];
}

- (void)_applicationWillResignActive:(NSNotification *)note
{
    if ([_delegate respondsToSelector:@selector(applicationWillResignActive:)]) {
        [_delegate applicationWillResignActive:self];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:UIApplicationWillResignActiveNotification object:self];
}

- (void)_applicationDidBecomeActive:(NSNotification *)note
{
    if ([_delegate respondsToSelector:@selector(applicationDidBecomeActive:)]) {
        [_delegate applicationDidBecomeActive:self];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:UIApplicationDidBecomeActiveNotification object:self];
}

@end


@implementation UIApplication(UIApplicationDeprecated)

- (void)setStatusBarHidden:(BOOL)hidden animated:(BOOL)animated
{
}

@end
