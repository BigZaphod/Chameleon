//  Created by Sean Heber on 6/25/10.
#import "UIBarItem.h"

@implementation UIBarItem
@synthesize enabled=_enabled, image=_image;

- (void)dealloc
{
	[_image release];
	[super dealloc];
}

@end
