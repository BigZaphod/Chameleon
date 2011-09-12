#import "UITableViewCellSelectedBackgroundView.h"
#import "UIImage+UIPrivate.h"


@implementation UITableViewCellSelectedBackgroundView
@synthesize selectionStyle = _selectionStyle;

- (void) setSelectionStyle:(UITableViewCellSelectionStyle)selectionStyle
{
    if (_selectionStyle != selectionStyle) {
        _selectionStyle = selectionStyle;
        [self setNeedsDisplay];
    }
}

- (void) drawRect:(CGRect)rect
{
    if (_selectionStyle == UITableViewCellSelectionStyleBlue) {
        [[UIImage _tableSelection] drawInRect:self.bounds];
    } else if (_selectionStyle == UITableViewCellSelectionStyleGray) {
        [[UIImage _tableSelectionGray] drawInRect:self.bounds];
    }
}

@end

