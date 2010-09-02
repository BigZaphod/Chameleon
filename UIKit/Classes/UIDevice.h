//  Created by Sean Heber on 6/18/10.
#import <Foundation/Foundation.h>

typedef enum {
	UIDeviceOrientationUnknown,
	UIDeviceOrientationPortrait,
	UIDeviceOrientationPortraitUpsideDown,
	UIDeviceOrientationLandscapeLeft,
	UIDeviceOrientationLandscapeRight,
	UIDeviceOrientationFaceUp,
	UIDeviceOrientationFaceDown
} UIDeviceOrientation;

typedef enum {
	UIUserInterfaceIdiomPhone,
	UIUserInterfaceIdiomPad,
	UIUserInterfaceIdiomDesktop,
} UIUserInterfaceIdiom;

#define UI_USER_INTERFACE_IDIOM() \
	([[UIDevice currentDevice] respondsToSelector:@selector(userInterfaceIdiom)] ? \
	[[UIDevice currentDevice] userInterfaceIdiom] : \
	UIUserInterfaceIdiomPhone)

@interface UIDevice : NSObject {
}

+ (UIDevice *)currentDevice;

@property (nonatomic, readonly, retain) NSString *name;
@property (nonatomic, readonly) UIUserInterfaceIdiom userInterfaceIdiom;					// always returns UIUserInterfaceIdiomPad, but maybe shouldn't?
@property (nonatomic, readonly) UIDeviceOrientation orientation;							// always returns UIDeviceOrientationPortrait
@property (nonatomic, readonly,getter=isMultitaskingSupported) BOOL multitaskingSupported;	// always returns YES
@property (nonatomic, readonly, retain) NSString *systemName;
@property (nonatomic, readonly, retain) NSString *systemVersion;
@property (nonatomic, readonly, retain) NSString *model;

@end
