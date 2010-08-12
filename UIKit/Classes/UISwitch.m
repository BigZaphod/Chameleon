//  Created by Sean Heber on 8/12/10.
#import "UISwitch.h"

@implementation UISwitch

- (id)initWithFrame:(CGRect)frame
{
	if ((self=[super initWithFrame:frame])) {		// this should enforce the proper size, etc. blah blah...
	}
	return self;
}

- (void)setOn:(BOOL)on animated:(BOOL)animated
{
}

- (void)setOn:(BOOL)on
{
	[self setOn:on animated:NO];
}

- (BOOL)isOn
{
	return NO;
}

@end
