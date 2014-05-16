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

#import "UIKitView.h"
#import "UIApplication.h"
#import "UIScreen+UIPrivate.h"
#import "UIScreenAppKitIntegration.h"
#import "UIWindow+UIPrivate.h"
#import "UIImage.h"
#import "UIImageView.h"
#import "UIColor.h"
#import "UITouchEvent.h"
#import "UITouch+UIPrivate.h"
#import "UIKey.h"
#import "UINSResponderShim.h"
#import "UIViewControllerAppKitIntegration.h"

/*
 An older design of Chameleon had the singlular multi-touch event living in UIApplication because that made sense at the time.
 However it was needlessly awkward to send events from here to the UIApplication and then have to decode them all again, etc.
 It seemingly gained nothing. Also, while I don't know how UIKit would handle this situation, I'm not sure it makes sense to
 have a single multitouch sequence span multiple screens anyway. There are some cases where that might kinda make sense, but
 I'm having some doubts that this is how iOS would be setup anyway. (It's hard to really know without some deep digging since
 I don't know if iOS even supports touch events on any screen other than the main one anyway, but it doesn't matter right now.)
 
 The benefit of having it here is that this is right where the touches happen. There's no ambiguity about exactly which
 screen/NSView the event occured on, and there's no need to pass that info around deep into other parts of the code, either.
 It can be dealt with here and now and life can go on and things don't have to get weirdly complicated deep down the rabbit
 hole. In theory.
 */

@interface UIKitView () <UINSResponderShimDelegate>
@end

@implementation UIKitView {
    UITouchEvent *_touchEvent;
    UITouch *_mouseMoveTouch;
    UIWindow *_UIWindow;
    NSTrackingArea *_trackingArea;
    UINSResponderShim *_responderShim;
}

- (id)initWithFrame:(NSRect)frame
{
    if ((self = [super initWithFrame:frame])) {
        _mouseMoveTouch = [[UITouch alloc] init];
        _UIScreen = [[UIScreen alloc] init];
        _responderShim = [[UINSResponderShim alloc] init];
        
        _responderShim.delegate = self;
        
        [self configureScreenLayer];
    }
    return self;
}

- (void)awakeFromNib
{
    [self configureScreenLayer];
}

- (void)configureScreenLayer
{
    [self setWantsLayer:YES];
    
    CALayer *screenLayer = [_UIScreen _layer];
    CALayer *myLayer = [self layer];
    
    [myLayer addSublayer:screenLayer];
    screenLayer.frame = myLayer.bounds;
    screenLayer.autoresizingMask = kCALayerWidthSizable | kCALayerHeightSizable;
}

- (UIWindow *)UIWindow
{
    if (!_UIWindow) {
        _UIWindow = [[UIWindow alloc] initWithFrame:_UIScreen.bounds];
        _UIWindow.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _UIWindow.screen = _UIScreen;
        [_UIWindow makeKeyAndVisible];
    }
    
    return _UIWindow;
}

- (BOOL)isFlipped
{
    return YES;
}

- (BOOL)acceptsFirstResponder
{
    // we want to accept, but we have to make sure one of our NSView children isn't already the first responder
    // because we don't want to let the mouse just steal that away here. If a pure-UIKit object gets clicked on
    // and decides to become first responder, it'll take it itself and things should sort itself out from there
    // (so stuff like a selected NSTextView would be resigned in the process of the new object becoming first
    // responder so we don't have to let AppKit handle it here in that case and returning NO should be okay
    // because by the time this is called again, the native AppKit control has already been told to resign)
    
    // the reason we can't just blindly accept first responder is that there are special situations like the
    // inputAccessoryViews which live inside our UIKitView and are implemented as UIKit code, but are often
    // used while the user has a native NSTextView as the first responder because they are typing in it. If
    // we didn't do this checking here, the click outside of the NSTextView would register as a click on this
    // UIKitView, and if we just returned YES here, AppKit would happily resign first responder from the text
    // view and set it for this UIKitView which causes the inputAccessoryView to disappear!
    
    NSResponder *responder = [(NSWindow *)[self window] firstResponder];
 
    while (responder) {
        if (responder == self) {
            return NO;
        } else {
            responder = [responder nextResponder];
        }
    }
    
    return YES;
}

- (void)updateUIKitView
{
    [_UIScreen _setUIKitView:(self.superview && self.window)? self : nil];
}

- (void)viewDidMoveToSuperview
{
    [super viewDidMoveToSuperview];
    [self updateUIKitView];
}

- (void)viewDidMoveToWindow
{
    [super viewDidMoveToWindow];
    [self updateUIKitView];
}

- (void)updateTrackingAreas
{
    [super updateTrackingAreas];
    [self removeTrackingArea:_trackingArea];
    _trackingArea = [[NSTrackingArea alloc] initWithRect:self.bounds options:NSTrackingCursorUpdate|NSTrackingMouseMoved|NSTrackingInVisibleRect|NSTrackingActiveInKeyWindow|NSTrackingMouseEnteredAndExited owner:self userInfo:nil];
    [self addTrackingArea:_trackingArea];
}

- (UIView *)hitTestUIView:(NSPoint)point
{
    NSMutableArray *sortedWindows = [_UIScreen.windows mutableCopy];
    [sortedWindows sortUsingDescriptors:@[[[NSSortDescriptor alloc] initWithKey:@"windowLevel" ascending:NO]]];
    
    for (UIWindow *window in sortedWindows) {
        const CGPoint windowPoint = [window convertPoint:point fromWindow:nil];
        UIView *hitView = [window hitTest:windowPoint withEvent:nil];
        if (hitView) return hitView;
    }
    
    return nil;
}

- (void)launchApplicationWithDefaultWindow:(UIWindow *)defaultWindow
{
    UIApplication *app = [UIApplication sharedApplication];
    id<UIApplicationDelegate> appDelegate = app.delegate;
    
    if ([appDelegate respondsToSelector:@selector(application:didFinishLaunchingWithOptions:)]) {
        [appDelegate application:app didFinishLaunchingWithOptions:nil];
    } else if ([appDelegate respondsToSelector:@selector(applicationDidFinishLaunching:)]) {
        [appDelegate applicationDidFinishLaunching:app];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:UIApplicationDidFinishLaunchingNotification object:app];
    
    if ([appDelegate respondsToSelector:@selector(applicationDidBecomeActive:)]) {
        [appDelegate applicationDidBecomeActive:app];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:UIApplicationDidBecomeActiveNotification object:app];
    
    defaultWindow.hidden = YES;
}

- (void)launchApplicationWithDelegate:(id<UIApplicationDelegate>)appDelegate afterDelay:(NSTimeInterval)delay
{
    [[UIApplication sharedApplication] setDelegate:appDelegate];
    
    if (delay) {
        UIImage *defaultImage = [UIImage imageNamed:@"Default-Landscape.png"];
        UIImageView *defaultImageView = [[UIImageView alloc] initWithImage:defaultImage];
        defaultImageView.contentMode = UIViewContentModeCenter;
        
        UIWindow *defaultWindow = [(UIWindow *)[UIWindow alloc] initWithFrame:_UIScreen.bounds];
        defaultWindow.userInteractionEnabled = NO;
        defaultWindow.screen = _UIScreen;
        defaultWindow.backgroundColor = [UIColor blackColor];	// dunno..
        defaultWindow.opaque = YES;
        [defaultWindow addSubview:defaultImageView];
        [defaultWindow makeKeyAndVisible];
        [self performSelector:@selector(launchApplicationWithDefaultWindow:) withObject:defaultWindow afterDelay:delay];
    } else {
        [self launchApplicationWithDefaultWindow:nil];
    }
}

#pragma mark responder chain muckery

- (void)setNextResponder:(NSResponder *)aResponder
{
    [super setNextResponder:_responderShim];
    [_responderShim setNextResponder:aResponder];
}

- (UIResponder *)responderForResponderShim:(UINSResponderShim *)shim
{
    UIWindow *keyWindow = _UIScreen.keyWindow;
    UIResponder *responder = [keyWindow _firstResponder];
    
    if (!responder) {
        UIViewController *controller = keyWindow.rootViewController;
        
        while (controller) {
            // for the sake of completeness, we check the controller's presentedViewController first, because such things are
            // supposed to kind of supercede the view controller itself - however we don't currently support them so it just
            // returns nil all the time anyway, but what the heck, eh?
            if (controller.presentedViewController) {
                controller = controller.presentedViewController;
            } else {
                UIViewController *childController = [controller defaultResponderChildViewController];
                
                if (childController) {
                    controller = childController;
                } else {
                    break;
                }
            }
        }
        
        responder = [controller defaultResponder];
    }
    
    return responder;
}

#pragma mark touch utilities

- (UITouch *)touchForEvent:(NSEvent *)theEvent
{
    const NSPoint location = [self convertPoint:[theEvent locationInWindow] fromView:nil];
    
    UITouch *touch = [[UITouch alloc] init];
    touch.view = [self hitTestUIView:location];
    touch.locationOnScreen = NSPointToCGPoint(location);
    touch.timestamp = [theEvent timestamp];
    
    return touch;
}

- (void)updateTouchLocation:(UITouch *)touch withEvent:(NSEvent *)theEvent
{
    _touchEvent.touch.locationOnScreen = NSPointToCGPoint([self convertPoint:[theEvent locationInWindow] fromView:nil]);
    _touchEvent.touch.timestamp = [theEvent timestamp];
}

- (void)cancelTouchesInView:(UIView *)view
{
    if (_touchEvent && _touchEvent.touch.phase != UITouchPhaseEnded && _touchEvent.touch.phase != UITouchPhaseCancelled) {
        if (!view || [view isDescendantOfView:_touchEvent.touch.view]) {
            _touchEvent.touch.phase = UITouchPhaseCancelled;
            _touchEvent.touch.timestamp = [NSDate timeIntervalSinceReferenceDate];
            [[UIApplication sharedApplication] sendEvent:_touchEvent];
            [_touchEvent endTouchEvent];
            _touchEvent = nil;
        }
    }
}

- (void)sendStationaryTouches
{
    if (_touchEvent && _touchEvent.touch.phase != UITouchPhaseEnded && _touchEvent.touch.phase != UITouchPhaseCancelled) {
        _touchEvent.touch.phase = UITouchPhaseStationary;
        _touchEvent.touch.timestamp = [NSDate timeIntervalSinceReferenceDate];
        [[UIApplication sharedApplication] sendEvent:_touchEvent];
    }
}

#pragma mark pseudo touch handling

- (void)mouseDown:(NSEvent *)theEvent
{
    if ([theEvent modifierFlags] & NSControlKeyMask) {
        // I don't really like this, but it seemed to be necessary.
        // If I override the menuForEvent: method, when you control-click it *still* sends mouseDown:, so I don't
        // really win anything by overriding that since I'd still need a check in here to prevent that mouseDown: from being
        // sent to UIKit as a touch. That seems really wrong, IMO. A right click should be independent of a touch event.
        // soooo.... here we are. Whatever. Seems to work. Don't really like it.
        [self rightMouseDown:[NSEvent mouseEventWithType:NSRightMouseDown location:[theEvent locationInWindow] modifierFlags:0 timestamp:[theEvent timestamp] windowNumber:[theEvent windowNumber] context:[theEvent context] eventNumber:[theEvent eventNumber] clickCount:[theEvent clickCount] pressure:[theEvent pressure]]];
        return;
    }
    
    // this is a special case to cancel any existing touches (as far as the client code is concerned) if the left
    // mouse button is pressed mid-gesture. the reason is that sometimes when using a magic mouse a user will intend
    // to click but if their finger moves against the surface ever so slightly, it will trigger a touch gesture to
    // begin instead. without this, the fact that we're in a touch gesture phase effectively overrules everything
    // else and clicks end up not getting registered. I don't think it's right to allow clicks to pass through when
    // we're in a gesture state since that'd be somewhat like a multitouch scenerio on an actual iOS device and we
    // are not really supporting anything like that at the moment.
    if (_touchEvent) {
        _touchEvent.touch.phase = UITouchPhaseCancelled;
        [self updateTouchLocation:_touchEvent.touch withEvent:theEvent];
        
        [[UIApplication sharedApplication] sendEvent:_touchEvent];
        
        [_touchEvent endTouchEvent];
        _touchEvent = nil;
    }
    
    if (!_touchEvent) {
        _touchEvent = [[UITouchEvent alloc] initWithTouch:[self touchForEvent:theEvent]];
        _touchEvent.touchEventGesture = UITouchEventGestureNone;
        _touchEvent.touch.tapCount = [theEvent clickCount];
        
        [[UIApplication sharedApplication] sendEvent:_touchEvent];
    }
}

- (void)mouseUp:(NSEvent *)theEvent
{
    if (_touchEvent && _touchEvent.touchEventGesture == UITouchEventGestureNone) {
        _touchEvent.touch.phase = UITouchPhaseEnded;
        [self updateTouchLocation:_touchEvent.touch withEvent:theEvent];

        [[UIApplication sharedApplication] sendEvent:_touchEvent];
        
        [_touchEvent endTouchEvent];
        _touchEvent = nil;
    }
}

- (void)mouseDragged:(NSEvent *)theEvent
{
    if (_touchEvent && _touchEvent.touchEventGesture == UITouchEventGestureNone) {
        _touchEvent.touch.phase = UITouchPhaseMoved;
        [self updateTouchLocation:_touchEvent.touch withEvent:theEvent];

        [[UIApplication sharedApplication] sendEvent:_touchEvent];
    }
}

#pragma mark touch gestures

- (void)beginGestureWithEvent:(NSEvent *)theEvent
{
    if (!_touchEvent) {
        _touchEvent = [[UITouchEvent alloc] initWithTouch:[self touchForEvent:theEvent]];
        _touchEvent.touchEventGesture = UITouchEventGestureBegin;

        [[UIApplication sharedApplication] sendEvent:_touchEvent];
    }
}

- (void)endGestureWithEvent:(NSEvent *)theEvent
{
    if (_touchEvent && _touchEvent.touchEventGesture != UITouchEventGestureNone) {
        _touchEvent.touch.phase = UITouchPhaseEnded;
        [self updateTouchLocation:_touchEvent.touch withEvent:theEvent];

        [[UIApplication sharedApplication] sendEvent:_touchEvent];
        
        [_touchEvent endTouchEvent];
        _touchEvent = nil;
    }
}

- (void)rotateWithEvent:(NSEvent *)theEvent
{
    if (_touchEvent && (_touchEvent.touchEventGesture == UITouchEventGestureBegin || _touchEvent.touchEventGesture == UITouchEventGestureRotate)) {
        _touchEvent.touch.phase = UITouchPhaseMoved;
        [self updateTouchLocation:_touchEvent.touch withEvent:theEvent];
        
        _touchEvent.touchEventGesture = UITouchEventGestureRotate;
        _touchEvent.rotation = [theEvent rotation];

        [[UIApplication sharedApplication] sendEvent:_touchEvent];
    }
}

- (void)magnifyWithEvent:(NSEvent *)theEvent
{
    if (_touchEvent && (_touchEvent.touchEventGesture == UITouchEventGestureBegin || _touchEvent.touchEventGesture == UITouchEventGesturePinch)) {
        _touchEvent.touch.phase = UITouchPhaseMoved;
        [self updateTouchLocation:_touchEvent.touch withEvent:theEvent];
        
        _touchEvent.touchEventGesture = UITouchEventGesturePinch;
        _touchEvent.magnification = [theEvent magnification];

        [[UIApplication sharedApplication] sendEvent:_touchEvent];
    }
}

- (void)swipeWithEvent:(NSEvent *)theEvent
{
    // it seems as if the swipe gesture actually is discrete as far as OSX is concerned and does not occur between gesture begin/end messages
    // which is sort of different.. but.. here we go. :) As a result, I'll require there to not be an existing touchEvent in play before a
    // swipe gesture is recognized.
    
    if (!_touchEvent) {
        UITouchEvent *swipeEvent = [[UITouchEvent alloc] initWithTouch:[self touchForEvent:theEvent]];
        swipeEvent.touchEventGesture = UITouchEventGestureSwipe;
        swipeEvent.translation = CGPointMake([theEvent deltaX], [theEvent deltaY]);
        [[UIApplication sharedApplication] sendEvent:swipeEvent];
        [swipeEvent endTouchEvent];
    }
}

#pragma mark scroll/pan gesture

- (void)scrollWheel:(NSEvent *)theEvent
{
    double dx, dy;
    
    CGEventRef cgEvent = [theEvent CGEvent];
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
    
    CGPoint translation = CGPointMake(-dx, -dy);

    // if this happens within an actual OSX gesture sequence, it is a pan touch gesture event
    // if it happens outside of a gesture, it is a normal mouse event instead
    // if it somehow happens during any other touch sequence, ignore it (someone might be click-dragging with the mouse and also using a wheel)
    
    if (_touchEvent) {
        if (_touchEvent.touchEventGesture == UITouchEventGestureBegin || _touchEvent.touchEventGesture == UITouchEventGesturePan) {
            _touchEvent.touch.phase = UITouchPhaseMoved;
            [self updateTouchLocation:_touchEvent.touch withEvent:theEvent];
            
            _touchEvent.touchEventGesture = UITouchEventGesturePan;
            _touchEvent.translation = translation;

            [[UIApplication sharedApplication] sendEvent:_touchEvent];
        }
    } else {
        UITouchEvent *mouseEvent = [[UITouchEvent alloc] initWithTouch:[self touchForEvent:theEvent]];
        mouseEvent.touchEventGesture = UITouchEventGestureScrollWheel;        
        mouseEvent.translation = translation;
        [[UIApplication sharedApplication] sendEvent:mouseEvent];
        [mouseEvent endTouchEvent];
    }
}

#pragma mark discrete mouse events

- (void)rightMouseDown:(NSEvent *)theEvent
{
    if (!_touchEvent) {
        UITouchEvent *mouseEvent = [[UITouchEvent alloc] initWithTouch:[self touchForEvent:theEvent]];
        mouseEvent.touchEventGesture = UITouchEventGestureRightClick;
        mouseEvent.touch.tapCount = [theEvent clickCount];
        [[UIApplication sharedApplication] sendEvent:mouseEvent];
        [mouseEvent endTouchEvent];
    }
}

- (void)mouseMoved:(NSEvent *)theEvent
{
    if (!_touchEvent) {
        const NSPoint location = [self convertPoint:[theEvent locationInWindow] fromView:nil];
        UIView *currentView = [self hitTestUIView:location];
        UIView *previousView = _mouseMoveTouch.view;
        
        _mouseMoveTouch.timestamp = [theEvent timestamp];
        _mouseMoveTouch.locationOnScreen = NSPointToCGPoint(location);
        _mouseMoveTouch.phase = UITouchPhaseMoved;
        
        if (previousView && previousView != currentView) {
            UITouchEvent *moveEvent = [[UITouchEvent alloc] initWithTouch:_mouseMoveTouch];
            moveEvent.touchEventGesture = UITouchEventGestureMouseMove;
            [[UIApplication sharedApplication] sendEvent:moveEvent];
            [moveEvent endTouchEvent];

            UITouchEvent *exitEvent = [[UITouchEvent alloc] initWithTouch:_mouseMoveTouch];
            exitEvent.touchEventGesture = UITouchEventGestureMouseExited;
            [[UIApplication sharedApplication] sendEvent:exitEvent];
            [exitEvent endTouchEvent];
        }
        
        _mouseMoveTouch.view = currentView;
        
        if (currentView) {
            if (currentView != previousView) {
                UITouchEvent *enterEvent = [[UITouchEvent alloc] initWithTouch:_mouseMoveTouch];
                enterEvent.touchEventGesture = UITouchEventGestureMouseEntered;
                [[UIApplication sharedApplication] sendEvent:enterEvent];
                [enterEvent endTouchEvent];
            }
            
            UITouchEvent *moveEvent = [[UITouchEvent alloc] initWithTouch:_mouseMoveTouch];
            moveEvent.touchEventGesture = UITouchEventGestureMouseMove;
            [[UIApplication sharedApplication] sendEvent:moveEvent];
            [moveEvent endTouchEvent];
        }
    }
}

- (void)mouseEntered:(NSEvent *)theEvent
{
    [self mouseMoved:theEvent];
}

- (void)mouseExited:(NSEvent *)theEvent
{
    if (!_touchEvent) {
        _mouseMoveTouch.phase = UITouchPhaseMoved;
        [self updateTouchLocation:_mouseMoveTouch withEvent:theEvent];
        
        UITouchEvent *moveEvent = [[UITouchEvent alloc] initWithTouch:_mouseMoveTouch];
        moveEvent.touchEventGesture = UITouchEventGestureMouseMove;
        [[UIApplication sharedApplication] sendEvent:moveEvent];
        [moveEvent endTouchEvent];
        
        UITouchEvent *exitEvent = [[UITouchEvent alloc] initWithTouch:_mouseMoveTouch];
        exitEvent.touchEventGesture = UITouchEventGestureMouseExited;
        [[UIApplication sharedApplication] sendEvent:exitEvent];
        [exitEvent endTouchEvent];
        
        _mouseMoveTouch.view = nil;
    }
}

#pragma keyboard events

- (void)keyDown:(NSEvent *)theEvent
{
    UIKey *key = [[UIKey alloc] initWithNSEvent:theEvent];
    
    // this is not the correct way to handle keys.. iOS 7 finally added a way to handle key commands
    // but this was implemented well before that. for now, this gets what we want to happen to happen.    
    
    if (key.action) {
        [self doCommandBySelector:key.action];
    } else {
        [super keyDown:theEvent];
    }
}

@end
