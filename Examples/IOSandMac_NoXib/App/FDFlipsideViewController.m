//
//  FDFlipsideViewController.m
//  IOSandMac_NoXib
//
//  Created by Dominik Pich on 07.02.13.
//  Copyright (c) 2013 Dominik Pich. All rights reserved.
//

#import "FDFlipsideViewController.h"

NSString *FDRacerModuleCell = @"FDRacerModuleCell";
#define kNavbarHeight 44

@interface FDFlipsideViewController ()
@property(strong, nonatomic) UITableView *tableView;
@property(nonatomic, strong) NSArray *sectionsWithRows;
@property(nonatomic, strong) NSString *activeModuleClassName;
#if !__has_feature(objc_arc)
@property(nonatomic, assign) UITableViewCell *selectedCell;
#else
@property(nonatomic, weak) UITableViewCell *selectedCell;
#endif
@end

@implementation FDFlipsideViewController
							
#pragma mark - lifecycle

- (void)loadView {
    [super loadView];
    UIView *v = super.view;
    CGRect bounds = v.bounds;
    
    CGRect navbarFrame = CGRectMake(0, 0, bounds.size.width, kNavbarHeight);
    UINavigationBar *aNavbar = [[UINavigationBar alloc] initWithFrame:navbarFrame];
    aNavbar.barStyle = UIBarStyleBlackOpaque;
    aNavbar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    UINavigationItem *aNavItem = [[UINavigationItem alloc] initWithTitle:NSLocalizedString(@"Settings", @"navigation bar title")];
    aNavItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(done:)];
    aNavbar.items = @[aNavItem];
    
    CGRect tableFrame = CGRectMake(0, kNavbarHeight, bounds.size.width, bounds.size.height - kNavbarHeight);
    UITableView *aTableview = [[UITableView alloc] initWithFrame:tableFrame style:UITableViewStyleGrouped];
    aTableview.delegate = self;
    aTableview.dataSource = self;

    v.backgroundColor = [UIColor whiteColor];
    [v addSubview:aNavbar];
    [v addSubview:aTableview];
    self.tableView = aTableview;
    self.view = v;
}

- (void)viewDidLoad {
    self.sectionsWithRows = @[];
}

#pragma mark - Actions

- (IBAction)done:(id)sender {
    [self.delegate flipsideViewControllerDidFinish:self];
}

#pragma mark - tableView stuff

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.sectionsWithRows.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)iSection {
    NSDictionary *section = self.sectionsWithRows[iSection];
    NSArray *rows = section[@"rows"];
    return rows.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)iSection {
    NSDictionary *section = self.sectionsWithRows[iSection];
    return section[@"title"];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *section = self.sectionsWithRows[indexPath.section];
    NSArray *rows = section[@"rows"];
    id value = section[rows];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:FDRacerModuleCell];
    if(!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:FDRacerModuleCell];
    }
    
    //TODO setup cell right
    NSString *name = [value description];
    BOOL selected = NO;
    
    cell.textLabel.text = name;
    cell.accessoryType = selected ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    if(selected) self.selectedCell = cell;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
