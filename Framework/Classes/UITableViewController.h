//  Created by Sean Heber on 6/29/10.
#import "UIViewController.h"
#import "UITableView.h"

@interface UITableViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
@private
	UITableViewStyle _style;
	BOOL _clearsSelectionOnViewWillAppear;
	BOOL _hasReloaded;
}

- (id)initWithStyle:(UITableViewStyle)style;

@property (nonatomic, retain) UITableView *tableView;
@property (nonatomic) BOOL clearsSelectionOnViewWillAppear;

@end
