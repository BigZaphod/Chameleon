//  Created by Sean Heber on 6/18/10.
#import "UIDevice.h"
#import <SystemConfiguration/SystemConfiguration.h>

static UIDevice *theDevice;

@implementation UIDevice
+ (void)initialize
{
	if (self == [UIDevice class]) {
		theDevice = [UIDevice new];
	}
}

+ (UIDevice *)currentDevice
{
	return theDevice;
}

- (id)init
{
	if ((self=[super init])) {
	}
	return self;
}

- (void)dealloc
{
	[super dealloc];
}

- (UIUserInterfaceIdiom)userInterfaceIdiom
{
	// LIES! This might not be the best way at this point, but we'll run with it for now...
	return UIUserInterfaceIdiomPad;
}

- (NSString *)name
{
	CFStringRef name = SCDynamicStoreCopyComputerName(NULL,NULL);
	return [(NSString *)name autorelease];
}

- (UIDeviceOrientation)orientation
{
	return UIDeviceOrientationPortrait;
}

- (BOOL)isMultitaskingSupported
{
	return YES;
}

@end
