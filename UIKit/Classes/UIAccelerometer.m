//  Created by Sean Heber on 8/16/10.
#import "UIAccelerometer.h"

@implementation UIAccelerometer
@synthesize updateInterval=_updateInterval, delegate=_delegate;

+ (UIAccelerometer *)sharedAccelerometer
{
	return nil;
}

@end
