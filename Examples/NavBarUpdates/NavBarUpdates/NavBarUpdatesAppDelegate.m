//
//  NavBarUpdatesAppDelegate.m
//  NavBarUpdates
//
//  Created by Jim Dovey on 11-03-22.
//  Copyright 2011 XPlatform Inc. All rights reserved.
//

#import "NavBarUpdatesAppDelegate.h"
#import "ChameleonAppDelegate.h"
#import <UIKit/UIKitView.h>

@implementation NavBarUpdatesAppDelegate

@synthesize window, chameleonNSView;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    chameleonApp = [[ChameleonAppDelegate alloc] init];
    [chameleonNSView launchApplicationWithDelegate:chameleonApp afterDelay:1];
}

- (void) dealloc
{
    [chameleonApp release];
    [super dealloc];
}

@end
