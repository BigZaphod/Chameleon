//  Created by Sean Heber on 6/25/10.
#import "UIToolbar.h"

@implementation UIToolbar
@synthesize barStyle=_barStyle, tintColor=_tintColor;

- (void)dealloc
{
	[_tintColor release];
	[super dealloc];
}

@end
