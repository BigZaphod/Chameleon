//  Created by Sean Heber on 6/25/10.
#import "UIAlertView.h"

@implementation UIAlertView
@synthesize cancelButtonIndex=_cancelButtonIndex;

- (id)initWithTitle:(NSString *)title message:(NSString *)message delegate:(id)delegate cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSString *)otherButtonTitles, ...
{
	if ((self=[super initWithFrame:CGRectZero])) {
	}
	return self;
}

- (void)dealloc
{
	[super dealloc];
}

- (void)show
{
}

@end
