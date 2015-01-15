
#import "AbstractCustomCell.h"
#import "CustomCellBackgroundView.h"
@implementation AbstractCustomCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
    {
        //optimise speed
        [self setOpaque:YES];
        
    }
    return self;
}



- (void) setSelectedColor:(UIColor *)color
{
    CustomCellBackgroundView *bkgView = [[CustomCellBackgroundView alloc] initWithFrame:self.frame];
    bkgView.fillColor =color;
	bkgView.borderColor = color;
	bkgView.position = self.tag;
    [self setSelectedBackgroundView:bkgView];
}

@end
