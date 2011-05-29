//
//  TestViewController.m
//  NavBarUpdates
//
//  Created by Jim Dovey on 11-03-22.
//  Copyright 2011 Jim Dovey. All rights reserved.
//

#import "TestViewController.h"
#import "UIRed.h"
#import "UIGreen.h"

@implementation TestViewController


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.

- (void)viewDidLoad {
	
	[super viewDidLoad];
	
	UIBarButtonItem *doneButton=[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:nil];
	self.navigationItem.rightBarButtonItem = doneButton;
	[doneButton release];
	
	
 
 }
 

- (void)loadView
{
	
	UIView *background=[[UIView alloc] init];
	background.backgroundColor=[UIColor whiteColor];
	
	UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 0, 0) style:UITableViewStyleGrouped];
	
	
	tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    tableView.delegate = self;
    tableView.dataSource = self;
	tableView.backgroundColor=[UIColor greenColor];
    [tableView reloadData];
	
	[background addSubview:tableView];
	
	
    self.view=background;
	self.view.autoresizesSubviews=YES;
}

#pragma mark -
#pragma mark Table view data source
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 80.0f;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView 
{
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
	
    return 30;
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
		
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }

	
	
	//cell.backgroundColor=[UIColor redColor];
	cell.selectionStyle=UITableViewCellSelectionStyleBlue;
    cell.textLabel.text=@"ABCD";
    cell.detailTextLabel.text=@"1234";
	/*
	UIRed *bg=[[UIRed alloc] initWithFrame:cell.frame];
	cell.backgroundView=bg;
	UIGreen *sbg=[[UIGreen alloc] initWithFrame:cell.frame];
	cell.selectedBackgroundView=sbg;*/
	
    return cell;
}


@end

