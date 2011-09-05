//
//  NavBarTableViewAppDelegate.m
//  NavBarTableView
//
//  Created by Jim Dovey on 11-03-22.
//  Copyright 2011 XPlatform Inc. All rights reserved.
//

#import "NavBarTableViewAppDelegate.h"
#import "ChameleonAppDelegate.h"
#import <UIKit/UIKitView.h>

@implementation NavBarTableViewAppDelegate

@synthesize window, chameleonNSView;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    chameleonApp = [[ChameleonAppDelegate alloc] init];
    [chameleonNSView launchApplicationWithDelegate:chameleonApp afterDelay:0];
}

- (void) dealloc
{
    [chameleonApp release];
    [super dealloc];
}

@end
