//  Created by Sean Heber on 6/25/10.
#import "UIActivityIndicatorView.h"

@implementation UIActivityIndicatorView
@synthesize hidesWhenStopped=_hidesWhenStopped;

- (id)initWithActivityIndicatorStyle:(UIActivityIndicatorViewStyle)style
{
	if ((self=[super initWithFrame:CGRectZero])) {
	}
	return self;
}

- (void)startAnimating
{
}

- (void)stopAnimating
{
}

@end
