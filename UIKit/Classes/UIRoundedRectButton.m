//  Created by Sean Heber on 6/24/10.
#import "UIRoundedRectButton.h"
#import "UIImage+UIPrivate.h"
#import "UIColor.h"

@implementation UIRoundedRectButton

- (id)initWithFrame:(CGRect)frame
{
	if ((self=[super initWithFrame:frame])) {
		_buttonType = UIButtonTypeRoundedRect;
	}
	return self;
}

- (UIColor *)_defaultTitleColor
{
	return [UIColor blackColor];
}

// Implemented using drawRect: since it seems the real rounded rect button is done that way, too since it still allows
// you to define background images on the button itself which then render on top of the rounded rect. So.... whatever :)
- (void)drawRect:(CGRect)rect
{
	[(self.highlighted? [UIImage _highlightedRoundedRectButtonImage] : [UIImage _roundedRectButtonImage]) drawInRect:self.bounds];
}

@end
