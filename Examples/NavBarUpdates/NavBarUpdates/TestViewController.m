//
//  TestViewController.m
//  NavBarUpdates
//
//  Created by Jim Dovey on 11-03-22.
//  Copyright 2011 Jim Dovey. All rights reserved.
//

#import "TestViewController.h"
#import "AbstractCustomCell.h"
#import "HMSegmentedControl.h"


@implementation TestViewController

- (void)viewDidLoad {
    myTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 44, self.view.bounds.size.width, self.view.bounds.size.height - 144)];
    
    myTableView.backgroundView = nil;
    [myTableView setDelegate:self];
    [myTableView setDataSource:self];
    myTableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    myTableView.autoresizesSubviews = YES;
    [self.view addSubview:myTableView];
    
    UIView *footer = [[UIView alloc]initWithFrame:CGRectMake(0, self.view.bounds.size.height - 100, self.view.bounds.size.width, 100)];
    footer.backgroundColor = [UIColor blackColor];
    footer.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    [self.view addSubview:footer];
    
    
    
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.view.backgroundColor = [UIColor whiteColor];
    
    HMSegmentedControl *segmentedControl = [[HMSegmentedControl alloc] initWithSectionTitles:@[@"All >"]];
    [segmentedControl setFrame:CGRectMake(0, 0, self.view.bounds.size.width, 45)];
    
    segmentedControl.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    [segmentedControl addTarget:self action:@selector(segmentedControlChangedValue:) forControlEvents:UIControlEventValueChanged];
    
    segmentedControl.selectionIndicatorStripLayerColor = [UIColor whiteColor];
    segmentedControl.selectionIndicatorBackgroundColor = [UIColor whiteColor]; // this will be a pale version of iosmailblue
    segmentedControl.selectionIndicatorBoxLayerColor = IOSMAILBLUE;
    [segmentedControl setTextColor:[UIColor whiteColor]];
    [segmentedControl setSelectedTextColor:[UIColor whiteColor]];
    segmentedControl.backgroundColor = IOSMAILBLUE;
    segmentedControl.font = [UIFont boldSystemFontOfSize:14];
    //   containerView0 = [[HMSegmentedControlContainerView alloc] initWithHMSegmentedControl:segmentedControl];
    [self.view addSubview:segmentedControl];
    segmentedControl.selectedSegmentIndex = 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 100;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AbstractCustomCell *cell = [[AbstractCustomCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"test"];
    cell.textLabel.text = @"Title";
    cell.textLabel.textColor = [UIColor whiteColor];
    
    cell.detailTextLabel.text = @"Subtitle";
    cell.detailTextLabel.textColor = [UIColor whiteColor];
    //  cell.contentView.backgroundColor = [UIColor blackColor];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    [cell setSelectedColor:[UIColor redColor]];
    return cell;
}

- (void)viewDidAppear:(BOOL)animated {
    [self.navigationItem performSelector:@selector(setTitle:) withObject:@"New Title" afterDelay:5.0];
}

@end
