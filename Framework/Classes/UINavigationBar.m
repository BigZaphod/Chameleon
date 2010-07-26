//  Created by Sean Heber on 6/25/10.
#import "UINavigationBar.h"

@implementation UINavigationBar
@synthesize tintColor=_tintColor;

- (void)dealloc
{
	[_tintColor release];
	[super dealloc];
}

- (UINavigationItem *)topItem
{
	return nil;
}

@end
