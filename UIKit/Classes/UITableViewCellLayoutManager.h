#import <Foundation/Foundation.h>
#import "UITableView.h"


@interface UITableViewCellLayoutManager : NSObject 

+ (id) layoutManagerForTableViewCellStyle:(UITableViewCellStyle)style;

// TODO: Add methods for calculating various view-rects based on the given
//       style.

@end
