//  Created by Sean Heber on 8/31/10.
#import "UIMenuItem.h"

@implementation UIMenuItem
@synthesize action=_action, title=_title;

- (id)initWithTitle:(NSString *)title action:(SEL)action
{
	if ((self=[super init])) {
		self.title = title;
		self.action = action;
	}
	return self;
}

- (void)dealloc
{
	[_title release];
	[super dealloc];
}

@end
