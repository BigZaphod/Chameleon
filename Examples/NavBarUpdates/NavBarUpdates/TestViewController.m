//
//  TestViewController.m
//  NavBarUpdates
//
//  Created by Jim Dovey on 11-03-22.
//  Copyright 2011 Jim Dovey. All rights reserved.
//

#import "TestViewController.h"


@implementation TestViewController

- (void) viewDidAppear: (BOOL) animated
{
	[self.navigationItem performSelector: @selector(setTitle:) withObject: @"New Title" afterDelay: 5.0];
}

@end
