//  Created by Sean Heber on 6/25/10.
#import "UIBarItem.h"

@implementation UIBarItem
@synthesize enabled=_enabled, image=_image, title=_title, tag=_tag;

- (void)dealloc
{
	[_image release];
	[_title release];
	[super dealloc];
}

@end
