//  Created by Sean Heber on 5/27/10.
#import <Foundation/Foundation.h>
#import <ApplicationServices/ApplicationServices.h>

extern NSString *const UIScreenDidConnectNotification;
extern NSString *const UIScreenDidDisconnectNotification;
extern NSString *const UIScreenModeDidChangeNotification;

@class UIImageView, CALayer, UIKitView, UIScreenMode, UIPopoverController;

@interface UIScreen : NSObject {
@private
	UIImageView *_grabber;
	CALayer *_layer;
	__weak UIKitView *_UIKitView;
	UIScreenMode *_currentMode;
	__weak UIPopoverController *_popoverController;
}

+ (UIScreen *)mainScreen;
+ (NSArray *)screens;

@property (nonatomic, readonly) CGRect bounds;
@property (nonatomic, readonly) CGRect applicationFrame;
@property (nonatomic,readonly,copy) NSArray *availableModes;	// only ever returns the currentMode
@property (nonatomic,retain) UIScreenMode *currentMode;			// ignores any attempt to set this (for now)
@property (nonatomic,readonly) CGFloat scale;					// always returns 1 for now

@end
