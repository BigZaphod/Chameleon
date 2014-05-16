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
#import "UIDevice.h"
#import "UIApplicationDelegate.h"

extern NSString *const UIApplicationWillChangeStatusBarOrientationNotification;
extern NSString *const UIApplicationDidChangeStatusBarOrientationNotification;
extern NSString *const UIApplicationWillEnterForegroundNotification;
extern NSString *const UIApplicationWillTerminateNotification;
extern NSString *const UIApplicationWillResignActiveNotification;
extern NSString *const UIApplicationDidEnterBackgroundNotification;
extern NSString *const UIApplicationDidBecomeActiveNotification;
extern NSString *const UIApplicationDidFinishLaunchingNotification;

extern NSString *const UIApplicationLaunchOptionsURLKey;
extern NSString *const UIApplicationLaunchOptionsSourceApplicationKey;
extern NSString *const UIApplicationLaunchOptionsRemoteNotificationKey;
extern NSString *const UIApplicationLaunchOptionsAnnotationKey;
extern NSString *const UIApplicationLaunchOptionsLocalNotificationKey;
extern NSString *const UIApplicationLaunchOptionsLocationKey;

extern NSString *const UIApplicationDidReceiveMemoryWarningNotification;

extern NSString *const UITrackingRunLoopMode;

typedef NS_ENUM(NSInteger, UIStatusBarStyle) {
  UIStatusBarStyleDefault,
  UIStatusBarStyleBlackTranslucent,
  UIStatusBarStyleBlackOpaque
};

typedef NS_ENUM(NSInteger, UIStatusBarAnimation) {
    UIStatusBarAnimationNone,
    UIStatusBarAnimationFade,
    UIStatusBarAnimationSlide,
};

typedef NS_ENUM(NSInteger, UIInterfaceOrientation) {
    UIInterfaceOrientationPortrait           = UIDeviceOrientationPortrait,
    UIInterfaceOrientationPortraitUpsideDown = UIDeviceOrientationPortraitUpsideDown,
    UIInterfaceOrientationLandscapeLeft      = UIDeviceOrientationLandscapeRight,
    UIInterfaceOrientationLandscapeRight     = UIDeviceOrientationLandscapeLeft
};

typedef NS_OPTIONS(NSUInteger, UIInterfaceOrientationMask) {
    UIInterfaceOrientationMaskPortrait = (1 << UIInterfaceOrientationPortrait),
    UIInterfaceOrientationMaskLandscapeLeft = (1 << UIInterfaceOrientationLandscapeLeft),
    UIInterfaceOrientationMaskLandscapeRight = (1 << UIInterfaceOrientationLandscapeRight),
    UIInterfaceOrientationMaskPortraitUpsideDown = (1 << UIInterfaceOrientationPortraitUpsideDown),
    UIInterfaceOrientationMaskLandscape = (UIInterfaceOrientationMaskLandscapeLeft | UIInterfaceOrientationMaskLandscapeRight),
    UIInterfaceOrientationMaskAll = (UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskLandscapeLeft | UIInterfaceOrientationMaskLandscapeRight | UIInterfaceOrientationMaskPortraitUpsideDown),
    UIInterfaceOrientationMaskAllButUpsideDown = (UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskLandscapeLeft | UIInterfaceOrientationMaskLandscapeRight),
};

#define UIInterfaceOrientationIsPortrait(orientation) \
((orientation) == UIInterfaceOrientationPortrait || \
(orientation) == UIInterfaceOrientationPortraitUpsideDown)

#define UIInterfaceOrientationIsLandscape(orientation) \
((orientation) == UIInterfaceOrientationLandscapeLeft || \
(orientation) == UIInterfaceOrientationLandscapeRight)

// push is not gonna work in mac os, unless you are apple (facetime)
typedef NS_OPTIONS(NSUInteger, UIRemoteNotificationType) {
    UIRemoteNotificationTypeNone    = 0,
    UIRemoteNotificationTypeBadge   = 1 << 0,
    UIRemoteNotificationTypeSound   = 1 << 1,
    UIRemoteNotificationTypeAlert   = 1 << 2,
    UIRemoteNotificationTypeNewsstandContentAvailability = 1 << 3
};

// whenever the NSApplication is no longer "active" from OSX's point of view, your UIApplication instance
// will switch to UIApplicationStateInactive. This happens when the app is no longer in the foreground, for instance.
// chameleon will also switch to the inactive state when the screen is put to sleep due to power saving mode.
// when the screen wakes up or the app is brought to the foreground, it is switched back to UIApplicationStateActive.
// 
// UIApplicationStateBackground is now supported and your app will transition to this state in two possible ways.
// one is when the AppKitIntegration method -terminateApplicationBeforeDate: is called. that method is intended to be
// used when your NSApplicationDelegate is being asked to terminate. the application is also switched to
// UIApplicationStateBackground when the machine is put to sleep. when the machine is reawakened, it will transition
// back to UIApplicationStateInactive (as per the UIKit docs). The OS tends to reactive the app in the usual way if
// it happened to be the foreground app when the machine was put to sleep, so it should ultimately work out as expected.
//
// any registered background tasks are allowed to complete whenever the app switches into UIApplicationStateBackground
// mode, so that means that when -terminateApplicationBeforeDate: is called directly, we will wait on background tasks
// and also show an alert to the user letting them know what's happening. it also means we attempt to delay machine
// sleep whenever sleep is initiated for as long as we can until any pending background tasks are completed. (there is no
// alert in that case) this should allow your app time to do any of the usual things like sync with network services or
// save state. just as on iOS, there's no guarentee you'll have time to complete you background task and there's no
// guarentee that your expiration handler will even be called. additionally, the reliability of your network is certainly
// going to be suspect when entering sleep as well. so be aware - but basically these same constraints exist on iOS so
// in many respects it shouldn't affect your code much or at all.
typedef NS_ENUM(NSInteger, UIApplicationState) {
  UIApplicationStateActive,
  UIApplicationStateInactive,
  UIApplicationStateBackground
};

typedef NSUInteger UIBackgroundTaskIdentifier;

extern const UIBackgroundTaskIdentifier UIBackgroundTaskInvalid;
extern const NSTimeInterval UIMinimumKeepAliveTimeout;

@class UIWindow, UIApplication, UILocalNotification;

@interface UIApplication : UIResponder
+ (UIApplication *)sharedApplication;

- (BOOL)sendAction:(SEL)action to:(id)target from:(id)sender forEvent:(UIEvent *)event;
- (void)sendEvent:(UIEvent *)event;

- (BOOL)openURL:(NSURL *)url;
- (BOOL)canOpenURL:(NSURL *)URL;

- (void)setStatusBarStyle:(UIStatusBarStyle)statusBarStyle animated:(BOOL)animated;  // no effect
- (void)setStatusBarHidden:(BOOL)hidden withAnimation:(UIStatusBarAnimation)animation;

- (void)beginIgnoringInteractionEvents;
- (void)endIgnoringInteractionEvents;
- (BOOL)isIgnoringInteractionEvents;

- (void)presentLocalNotificationNow:(UILocalNotification *)notification;
- (void)cancelLocalNotification:(UILocalNotification *)notification;
- (void)cancelAllLocalNotifications;

- (void)registerForRemoteNotificationTypes:(UIRemoteNotificationType)types;
- (void)unregisterForRemoteNotifications;
- (UIRemoteNotificationType)enabledRemoteNotificationTypes;

- (UIBackgroundTaskIdentifier)beginBackgroundTaskWithExpirationHandler:(void(^)(void))handler;
- (void)endBackgroundTask:(UIBackgroundTaskIdentifier)identifier;

@property (nonatomic, weak, readonly) UIWindow *keyWindow;
@property (nonatomic, readonly) NSArray *windows;
@property (nonatomic, getter=isStatusBarHidden, readonly) BOOL statusBarHidden;
@property (nonatomic, readonly) CGRect statusBarFrame;
@property (nonatomic, getter=isNetworkActivityIndicatorVisible) BOOL networkActivityIndicatorVisible;	// does nothing, always returns NO
@property (nonatomic) UIInterfaceOrientation statusBarOrientation;
@property (nonatomic, readonly) NSTimeInterval statusBarOrientationAnimationDuration;
@property (nonatomic, assign) id<UIApplicationDelegate> delegate;
@property (nonatomic, getter=isIdleTimerDisabled) BOOL idleTimerDisabled;	// has no actual affect
@property (nonatomic) BOOL applicationSupportsShakeToEdit;					// no effect
@property (nonatomic) UIStatusBarStyle statusBarStyle;                      // always returns UIStatusBarStyleDefault
@property (nonatomic, readonly) UIApplicationState applicationState;        // see notes near UIApplicationState struct for details!
@property (nonatomic, readonly) NSTimeInterval backgroundTimeRemaining;     // always 0
@property (nonatomic) NSInteger applicationIconBadgeNumber;                 // no effect, but does set/get the number correctly
@property (nonatomic, copy) NSArray *scheduledLocalNotifications;           // no effect, returns nil
@end

@interface UIApplication(UIApplicationDeprecated)
- (void)setStatusBarHidden:(BOOL)hidden animated:(BOOL)animated __attribute__((deprecated)); // use -setStatusBarHidden:withAnimation:
@end

// This can replace your call to NSApplicationMain. It does not implement NSApplicationMain exactly (and it never calls NSApplicationMain)
// so you should use this with some caution. It does *not* subclass NSApplication but does allow you to subclass UIApplication if you want,
// although that's not really tested so it probably wouldn't work very well. It sets NSApplication's delegate to a very simple dummy object
// which traps -applicationShouldTerminate: to handle background tasks so you don't have to bother with it. Like NSApplicationMain, this
// looks for a NIB file in the Info.plist identified by the NSMainNibFile key and will load it using AppKit's NIB loading stuff. In an
// attempt to make this as confusing as possible, when the main NIB is loaded, it uses the UIApplication (NOT THE NSApplication!) as the
// file's owner! Yep. Insane, I know. I generally do not use NIBs myself, but it's nice for the menu bar. So... yeah...
// NOTE: This does not use NSPrincipalClass from Info.plist since iOS doesn't either, so if that exists in your Info.plist, it is ignored.
extern int UIApplicationMain(int argc, char *argv[], NSString *principalClassName, NSString *delegateClassName);
