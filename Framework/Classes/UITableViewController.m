//  Created by Sean Heber on 6/29/10.
#import "UITableViewController.h"

@implementation UITableViewController
@synthesize clearsSelectionOnViewWillAppear=_clearsSelectionOnViewWillAppear;

- (id)init
{
	return [self initWithStyle:UITableViewStylePlain];
}

- (id)initWithStyle:(UITableViewStyle)theStyle
{
	if ((self=[super initWithNibName:nil bundle:nil])) {
		_style = theStyle;
	}
	return self;
}

- (void)loadView
{
	self.tableView = [[[UITableView alloc] initWithStyle:_style] autorelease];
	self.tableView.delegate = self;
	self.tableView.dataSource = self;
}

- (UITableView *)tableView
{
	return (UITableView *)self.view;
}

- (void)setTableView:(UITableView *)theTableView
{
	self.view = theTableView;
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];

	if (!_hasReloaded) {
		[self.tableView reloadData];
		_hasReloaded = YES;
	}
	
	if (_clearsSelectionOnViewWillAppear) {
		[self.tableView deselectRowAtIndexPath:self.tableView.indexPathForSelectedRow animated:animated];
	}
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	[self.tableView flashScrollIndicators];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return nil;
}

@end
