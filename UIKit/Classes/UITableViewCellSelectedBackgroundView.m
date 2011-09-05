#import "UITableViewCellSelectedBackgroundView.h"
#import "UIImage+UIPrivate.h"


@implementation UITableViewCellSelectedBackgroundView
@synthesize selectionStyle = selectionStyle_;

- (void) setSelectionStyle:(UITableViewCellSelectionStyle)selectionStyle
{
    if (selectionStyle_ != selectionStyle) {
        selectionStyle_ = selectionStyle;
        [self setNeedsDisplay];
    }
}

- (void) drawRect:(CGRect)rect
{
    if (selectionStyle_ == UITableViewCellSelectionStyleBlue) {
        [[UIImage _tableSelection] drawInRect:self.bounds];
    } else if (selectionStyle_ == UITableViewCellSelectionStyleGray) {
        [[UIImage _tableSelectionGray] drawInRect:self.bounds];
    }
}

@end

