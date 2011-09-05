#import "UITableView.h"

@interface UITableView ()
@property (nonatomic) BOOL allowsMultipleSelection;
@property (nonatomic, readonly) NSArray *selectedRows;
@end

@interface UITableView (AppKitIntegration)
- (void)selectRowAtIndexPath:(NSIndexPath *)indexPath exclusively:(BOOL)exclusively animated:(BOOL)animated scrollPosition:(UITableViewScrollPosition)scrollPosition;
- (void)deselectAllRowsAnimated:(BOOL)animated;
@end