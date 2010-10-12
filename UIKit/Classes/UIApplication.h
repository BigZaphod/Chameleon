//  Created by Sean Heber on 5/28/10.
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

extern NSString *const UITrackingRunLoopMode;

typedef enum {
	UIInterfaceOrientationPortrait           = UIDeviceOrientationPortrait,
	UIInterfaceOrientationPortraitUpsideDown = UIDeviceOrientationPortraitUpsideDown,
	UIInterfaceOrientationLandscapeLeft      = UIDeviceOrientationLandscapeRight,
	UIInterfaceOrientationLandscapeRight     = UIDeviceOrientationLandscapeLeft
} UIInterfaceOrientation;

#define UIInterfaceOrientationIsPortrait(orientation) \
((orientation) == UIInterfaceOrientationPortrait || \
(orientation) == UIInterfaceOrientationPortraitUpsideDown)

#define UIInterfaceOrientationIsLandscape(orientation) \
((orientation) == UIInterfaceOrientationLandscapeLeft || \
(orientation) == UIInterfaceOrientationLandscapeRight)

@class UIWindow, UIApplication;

@interface UIApplication : UIResponder {
@private
	UIEvent *_currentEvent;
	__weak UIWindow *_keyWindow;
	NSMutableSet *_visibleWindows;
	NSMutableSet *_visiblePopovers;
	id<UIApplicationDelegate> _delegate;
	BOOL _idleTimerDisabled;
}

+ (UIApplication *)sharedApplication;

- (BOOL)sendAction:(SEL)action to:(id)target from:(id)sender forEvent:(UIEvent *)event;
- (void)sendEvent:(UIEvent *)event;
- (BOOL)openURL:(NSURL *)url;

- (void)beginIgnoringInteractionEvents;
- (void)endIgnoringInteractionEvents;

@property (nonatomic, readonly) UIWindow *keyWindow;
@property (nonatomic, readonly) NSArray *windows;
@property (nonatomic, getter=isStatusBarHidden, readonly) BOOL statusBarHidden;
@property (nonatomic, getter=isNetworkActivityIndicatorVisible) BOOL networkActivityIndicatorVisible;	// does nothing, always returns NO
@property (nonatomic) UIInterfaceOrientation statusBarOrientation;
@property (nonatomic, readonly) NSTimeInterval statusBarOrientationAnimationDuration;
@property (nonatomic, assign) id<UIApplicationDelegate> delegate;
@property (nonatomic, getter=isIdleTimerDisabled) BOOL idleTimerDisabled;	// has no actual affect

@end
