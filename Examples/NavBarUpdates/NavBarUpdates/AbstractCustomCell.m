#import "AbstractCustomCell.h"
#import "CustomCellBackgroundView.h"
@implementation AbstractCustomCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        //optimise speed
        [self setOpaque:YES];
    }
    return self;
}

- (void)setSelectedColor:(UIColor *)color {
    CustomCellBackgroundView *bkgView = [[CustomCellBackgroundView alloc] initWithFrame:self.frame];
    bkgView.fillColor = color;
    bkgView.borderColor = color;
    bkgView.position = self.tag;
    [self setSelectedBackgroundView:bkgView];
}

- (void)mouseEntered:(UIView *)view withEvent:(UIEvent *)event {
    NSLog(@"mouseEntered");
    
    [self setHighlighted:YES animated:YES];
    self.backgroundColor = IOS7SELECTEDGRAY;
}

- (void)mouseExited:(UIView *)view withEvent:(UIEvent *)event {
    NSLog(@"mouseExited");
    [self setHighlighted:NO animated:YES];
    self.backgroundColor = [UIColor whiteColor];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
    if (selected) {
        //make all fonts to light
        self.textLabel.textColor = [UIColor whiteColor];
        [self setNeedsDisplay];
    }
    else {
        self.textLabel.textColor = IOS7BLUE;
    }
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    [super setHighlighted:highlighted animated:animated];
    
    if (highlighted) {
        //make all fonts to light
        self.textLabel.textColor = [UIColor whiteColor];
    }
    else {
        self.textLabel.textColor = IOS7BLUE;
    }
    [self setNeedsDisplay];
}

@end
