//
//  FDMainViewController.m
//  IOSandMac_NoXib
//
//  Created by Dominik Pich on 07.02.13.
//  Copyright (c) 2013 Dominik Pich. All rights reserved.
//

#import "FDMainViewController.h"

#define kToolbarHeight 48

@interface FDMainViewController ()
@property(nonatomic, retain) UIToolbar *toolbar;
@property(nonatomic, retain) UIBarButtonItem *spacerButton;
@property(nonatomic, retain) UIBarButtonItem *infoButton;

@property (strong, nonatomic) FDFlipsideViewController *flipsideViewController;
@property (strong, nonatomic) UIPopoverController *flipsidePopoverController;
@end

@implementation FDMainViewController

- (BOOL)isIPhone {
    return [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone;
}

- (BOOL)isMac {
#if TARGET_OS_IPHONE
    return NO;
#else
    return [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomDesktop;
#endif
}

#pragma mark - lifecycle

- (void)loadView {
    [super loadView];
    UIView *v = super.view;
    CGRect bounds = v.bounds;
    
    CGRect toolbarFrame = CGRectMake(0, bounds.size.height - kToolbarHeight, bounds.size.width, kToolbarHeight);
    UIToolbar *aToolbar = [[UIToolbar alloc] initWithFrame:toolbarFrame];
    aToolbar.barStyle = UIBarStyleBlack;
    aToolbar.translucent = YES;
    aToolbar.autoresizingMask =  UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
    
    [v addSubview:aToolbar];
    self.toolbar = aToolbar;
    v.backgroundColor = [UIColor yellowColor];
    self.view = v;
}

#pragma mark - Actions

- (IBAction)showInfo:(id)sender {
    if(self.isIPhone || self.isMac) {
        [self presentModalViewController:self.flipsideViewController animated:YES];
    } else {
        if ([self.flipsidePopoverController isPopoverVisible]) {
            [self.flipsidePopoverController dismissPopoverAnimated:YES];
        } else {
            [self.flipsidePopoverController presentPopoverFromBarButtonItem:self.infoButton permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        }
    }
}

- (void)viewDidLoad {
    NSArray *toolbarItems;
    
    if(!self.spacerButton) self.spacerButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    if(!self.infoButton) self.infoButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(showInfo:)];

    toolbarItems = @[self.spacerButton, self.infoButton];
    [self.toolbar setItems:toolbarItems animated:YES];
}

#pragma mark - Flipside View Controller

- (FDFlipsideViewController*)flipsideViewController {
    if(!_flipsideViewController) {
        _flipsideViewController = [[FDFlipsideViewController alloc] init];
        _flipsideViewController.delegate = self;
        _flipsideViewController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
        _flipsideViewController.contentSizeForViewInPopover = CGSizeMake(320.0, 480.0);
    }
    return _flipsideViewController;
}

- (UIPopoverController *)flipsidePopoverController {
    if (!_flipsidePopoverController) {
        _flipsidePopoverController = [[UIPopoverController alloc] initWithContentViewController:self.flipsideViewController];
    }
    return _flipsidePopoverController;
}

- (void)flipsideViewControllerDidFinish:(FDFlipsideViewController *)controller {
    if (self.isIPhone || self.isMac) {
        [self dismissModalViewControllerAnimated:YES];
    } else {
        [self.flipsidePopoverController dismissPopoverAnimated:YES];
        self.flipsidePopoverController = nil;
    }
    self.flipsideViewController = nil;
}

@end
