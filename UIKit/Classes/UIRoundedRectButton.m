//  Created by Sean Heber on 6/24/10.
#import "UIRoundedRectButton.h"
#import "UIImage+UIPrivate.h"
#import "UIColor.h"

static UIImage *highlightedImage = nil;
static UIImage *normalImage = nil;

@implementation UIRoundedRectButton

+ (void)initialize
{
	if (self == [UIRoundedRectButton class]) {
		normalImage = [[[UIImage _frameworkImageNamed:@"<UIRoundedRectButton> normal.png"] stretchableImageWithLeftCapWidth:12 topCapHeight:9] retain];
		highlightedImage = [[[UIImage _frameworkImageNamed:@"<UIRoundedRectButton> highlighted.png"] stretchableImageWithLeftCapWidth:12 topCapHeight:9] retain];
	}
}

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
	[(self.highlighted? highlightedImage : normalImage) drawInRect:self.bounds];
}

@end
