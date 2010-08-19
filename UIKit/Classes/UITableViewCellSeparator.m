//  Created by Sean Heber on 6/4/10.
#import "UITableViewCellSeparator.h"
#import "UIColor.h"
#import "UIGraphics.h"

@implementation UITableViewCellSeparator

- (id)initWithFrame:(CGRect)frame
{
	if ((self=[super initWithFrame:frame])) {
		_style = UITableViewCellSeparatorStyleNone;
		self.hidden = YES;
	}
	return self;
}

- (void)setSeparatorStyle:(UITableViewCellSeparatorStyle)theStyle color:(UIColor *)theColor
{
	if (_style != theStyle) {
		_style = theStyle;
		[self setNeedsDisplay];
	}

	if (_color != theColor) {
		[_color release];
		_color = [theColor retain];
		[self setNeedsDisplay];
	}
	
	self.hidden = (_style == UITableViewCellSeparatorStyleNone);
}

- (void)drawRect:(CGRect)rect
{
	if (_color) {
		if (_style == UITableViewCellSeparatorStyleSingleLine) {
			[_color setFill];
			CGContextFillRect(UIGraphicsGetCurrentContext(),CGRectMake(0,0,self.bounds.size.width,1));
		}
	}
}

@end
