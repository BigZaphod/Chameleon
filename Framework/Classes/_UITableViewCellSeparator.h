//  Created by Sean Heber on 6/4/10.
#import "UIView.h"
#import "UITableViewCell.h"

@class UIColor;

@interface _UITableViewCellSeparator : UIView {
@private
	UITableViewCellSeparatorStyle _style;
	UIColor *_color;
}

- (void)setSeparatorStyle:(UITableViewCellSeparatorStyle)theStyle color:(UIColor *)theColor;

@end
