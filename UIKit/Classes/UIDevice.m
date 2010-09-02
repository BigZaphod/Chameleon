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
	return UIUserInterfaceIdiomDesktop;
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

- (NSString *)systemName
{
	return [[NSProcessInfo processInfo] operatingSystemName];
}

- (NSString *)systemVersion
{
	return [[NSProcessInfo processInfo] operatingSystemVersionString];
}

- (NSString *)model
{
	return @"Mac";
}

@end
