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


@interface ToolbarView : NSView


@end
@implementation ToolbarView

- (void)drawRect:(NSRect)dirtyRect {
    [[NSColor redColor]set];
}

@end
@implementation NavBarUpdatesAppDelegate

@synthesize window, chameleonNSView;



- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    //  [window supportsVibrantAppearances];
    // [window setContentViewAppearanceVibrantDark];
    [window setTitleBarHeight:200];
    window.hidesTitle = NO;
    ToolbarView *test = [[ToolbarView alloc]initWithFrame:CGRectMake(0, 0, 300, 200)];
    [window.titleBarView addSubview:test];
    
    chameleonApp = [[ChameleonAppDelegate alloc] init];
    [chameleonNSView launchApplicationWithDelegate:chameleonApp afterDelay:1];
}

@end
