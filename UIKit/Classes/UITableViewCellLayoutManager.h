//#import <Foundation/Foundation.h>
//#import "UITableView.h"
#import <UIKit/UIKit.h>

@interface UITableViewCellLayoutManager : NSObject 

+ (id) layoutManagerForTableViewCellStyle:(UITableViewCellStyle)style;

- (CGRect) contentViewRectForCell:(UITableViewCell*)cell;
- (CGRect) accessoryViewRectForCell:(UITableViewCell*)cell;
- (CGRect) backgroundViewRectForCell:(UITableViewCell*)cell;
- (CGRect) seperatorViewRectForCell:(UITableViewCell*)cell;
- (CGRect) imageViewRectForCell:(UITableViewCell*)cell;
- (CGRect) textLabelRectForCell:(UITableViewCell*)cell;
- (CGRect) detailTextLabelRectForCell:(UITableViewCell*)cell;

@end

@interface UITableViewCellLayoutManagerDefault : UITableViewCellLayoutManager
    
@end