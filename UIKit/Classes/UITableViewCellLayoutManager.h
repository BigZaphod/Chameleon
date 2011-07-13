#import <Foundation/Foundation.h>
#import "UITableView.h"


@interface UITableViewCellLayoutManager : NSObject 

+ (id) layoutManagerForTableViewCellStyle:(UITableViewCellStyle)style;

- (CGRect) contentRectForCell:(UITableViewCell*)cell;
- (CGRect) accessoryRectForCell:(UITableViewCell*)cell;
- (CGRect) backgroundRectForCell:(UITableViewCell*)cell;
- (CGRect) seperatorRectForCell:(UITableViewCell*)cell;
- (CGRect) textLabelRectForCell:(UITableViewCell*)cell;

@end

@interface UITableViewCellLayoutManagerDefault : UITableViewCellLayoutManager
    
@end