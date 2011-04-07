//
//  TestViewController.m
//  NavBarUpdates
//
//  Created by Jim Dovey on 11-03-22.
//  Copyright 2011 Jim Dovey. All rights reserved.
//

#import "TestViewController.h"

@implementation TestViewController

- (void) viewDidLoad
{
    UINSCellControl * checkbox = [UINSCellControl checkboxWithFrame: CGRectMake(20.0, 20.0, 140.0, 40.0)];
    checkbox.title = @"I'm unchecked";
    checkbox.selected = NO;
    [checkbox addTarget: self action: @selector(toggledCheckbox:) forControlEvents: UIControlEventValueChanged];
    
    [self.view addSubview: checkbox];
}

- (void) viewDidAppear: (BOOL) animated
{
    [self.navigationItem performSelector: @selector(setTitle:) withObject: @"New Title" afterDelay: 5.0];
}

- (void) toggledCheckbox: (UINSCellControl *) checkbox
{
    if ( checkbox.selected )
        checkbox.title = @"I'm checked!";
    else
        checkbox.title = @"I'm unchecked";
}

@end
