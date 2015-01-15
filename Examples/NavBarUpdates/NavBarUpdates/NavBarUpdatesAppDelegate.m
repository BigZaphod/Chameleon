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
#import "TitleBarView.h"
#import "MyTitleBarViewController.h"


@implementation NavBarUpdatesAppDelegate

@synthesize window, chameleonNSView;

- (void)configureTitleBar {
    NSView *themeView = [[window contentView] superview];
    
    NSArray *array = [themeView subviews];
    NSView *subview2 = [array objectAtIndex:0];
    NSView *subsubView1 = [subview2 subviews].firstObject;
    NSButton *testbtn = [[NSButton alloc] initWithFrame:CGRectMake(50, 50, 40, 20)];
    [testbtn setTitle:@"test"];
    TitleBackGroudView *titleBgView = [[[TitleBackGroudView alloc] initWithFrame:CGRectMake(0, 0, 400, 137)] autorelease];
    
    //    [themeView addSubview:titleBgView positioned:NSWindowBelow relativeTo:subview2];
    [subview2 addSubview:titleBgView positioned:NSWindowBelow relativeTo:subsubView1];
    
    [window.titleBarVc.view addSubview:testbtn];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    [self configureTitleBar];
    chameleonApp = [[ChameleonAppDelegate alloc] init];
    [chameleonNSView launchApplicationWithDelegate:chameleonApp afterDelay:1];
}

- (void)dealloc {
    [chameleonApp release];
    [super dealloc];
}

@end
