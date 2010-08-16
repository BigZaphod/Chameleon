//  Created by Sean Heber on 5/27/10.
#import <Foundation/Foundation.h>
#import <ApplicationServices/ApplicationServices.h>

extern NSString *const UIScreenDidConnectNotification;
extern NSString *const UIScreenDidDisconnectNotification;
extern NSString *const UIScreenModeDidChangeNotification;

@class UIImageView, CALayer, NSView, UIScreenMode, UIPopoverController;

@interface UIScreen : NSObject {
@private
	UIImageView *_grabber;
	CALayer *_layer;
	NSView *_NSView;
	UIScreenMode *_currentMode;
	__weak UIPopoverController *_popoverController;
}

+ (UIScreen *)mainScreen;
+ (NSArray *)screens;

@property (nonatomic, readonly) CGRect bounds;
@property (nonatomic, readonly) CGRect applicationFrame;
@property (nonatomic,readonly,copy) NSArray *availableModes;	// only ever returns the currentMode
@property (nonatomic,retain) UIScreenMode *currentMode;			// ignores any attempt to set this (for now)

@end

// These are not actually part of the real UIKit
@interface UIScreen (Extensions)
// promptes this screen to the main screen
// this only changes what [UIScreen mainScreen] returns in the future, it doesn't move anything between views, etc.
- (void)becomeMainScreen;

// Using a nil screen will convert to OSX screen coordinates.
- (CGPoint)convertPoint:(CGPoint)toConvert toScreen:(UIScreen *)toScreen;
- (CGPoint)convertPoint:(CGPoint)toConvert fromScreen:(UIScreen *)fromScreen;
- (CGRect)convertRect:(CGRect)toConvert toScreen:(UIScreen *)toScreen;
- (CGRect)convertRect:(CGRect)toConvert fromScreen:(UIScreen *)fromScreen;
@end
