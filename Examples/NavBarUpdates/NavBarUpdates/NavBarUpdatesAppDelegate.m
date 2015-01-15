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


@interface BlackTitlebarView : NSView
@end
@implementation BlackTitlebarView


- (void)drawString:(NSString *)string inRect:(NSRect)rect {
    static NSDictionary *att = nil;
    if (!att) {
        NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
        [style setLineBreakMode:NSLineBreakByTruncatingTail];
        [style setAlignment:NSCenterTextAlignment];
        att = [[NSDictionary alloc] initWithObjectsAndKeys:style, NSParagraphStyleAttributeName, [NSColor whiteColor], NSForegroundColorAttributeName, [NSFont fontWithName:@"Helvetica" size:18], NSFontAttributeName, nil];
    }
    
    NSRect titlebarRect = NSMakeRect(rect.origin.x + 20, rect.origin.y - 4, rect.size.width, rect.size.height);
    
    
    [string drawInRect:titlebarRect withAttributes:att];
}

- (void)drawRect:(NSRect)dirtyRect {
    [[NSColor darkGrayColor] set];
    NSRectFill(dirtyRect);
    
    [self drawString:@"My Title" inRect:dirtyRect];
}

@end
@implementation ToolbarView

- (void)drawRect:(NSRect)dirtyRect {
    [[NSColor redColor]set];
}

@end
@implementation NavBarUpdatesAppDelegate

@synthesize window, chameleonNSView;



- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    NSRect boundsRect = [[[window contentView] superview] bounds];
    BlackTitlebarView *titleview = [[BlackTitlebarView alloc] initWithFrame:boundsRect];
    [titleview setAutoresizingMask:(NSViewWidthSizable | NSViewHeightSizable)];
    
    [[[window contentView] superview] addSubview:titleview positioned:NSWindowBelow relativeTo:[[[[window contentView] superview] subviews] objectAtIndex:0]];
    
    
    
    chameleonApp = [[ChameleonAppDelegate alloc] init];
    [chameleonNSView launchApplicationWithDelegate:chameleonApp afterDelay:1];
}

@end
