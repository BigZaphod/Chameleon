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


@interface BlackTitlebarView : NSView {
    BOOL highlighted;
}
@end
@implementation BlackTitlebarView

- (id)initWithFrame:(NSRect)frameRect {
    self = [super initWithFrame:frameRect];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:@"isActive" object:nil queue:[NSOperationQueue mainQueue] usingBlock: ^(NSNotification *note) {
        NSLog(@"ok");
        highlighted = YES;
        [self setNeedsDisplay:YES];
    }];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:@"isInactive" object:nil queue:[NSOperationQueue mainQueue] usingBlock: ^(NSNotification *note) {
        NSLog(@"ok");
        highlighted = NO;
        [self setNeedsDisplay:YES];
    }];
    return self;
}

- (void)drawString:(NSString *)string inRect:(NSRect)rect {
    static NSDictionary *att = nil;
    if (!att) {
        NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
        [style setLineBreakMode:NSLineBreakByTruncatingTail];
        [style setAlignment:NSCenterTextAlignment];
        att = [[NSDictionary alloc] initWithObjectsAndKeys:style, NSParagraphStyleAttributeName, [NSColor whiteColor], NSForegroundColorAttributeName, [NSFont fontWithName:@"Helvetica" size:22], NSFontAttributeName, nil];
    }
    
    NSRect titlebarRect = NSMakeRect(rect.origin.x + 20, rect.origin.y - 4, rect.size.width, rect.size.height);
    
    
    [string drawInRect:titlebarRect withAttributes:att];
}

- (void)drawRect:(NSRect)dirtyRect {
    if (highlighted) {
        [[NSColor darkGrayColor] set];
    }
    else {
        [[NSColor lightGrayColor] set];
    }
    
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

- (void)applicationDidResignActive:(NSNotification *)notification {
    [[NSNotificationCenter defaultCenter] performSelectorOnMainThread:@selector(postNotification:) withObject:[NSNotification notificationWithName:@"isInactive"   object:self userInfo:nil] waitUntilDone:NO];
}

- (void)applicationDidBecomeActive:(NSNotification *)notification {
    [[NSNotificationCenter defaultCenter] performSelectorOnMainThread:@selector(postNotification:) withObject:[NSNotification notificationWithName:@"isActive"   object:self userInfo:nil] waitUntilDone:NO];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    NSRect boundsRect = [[[window contentView] superview] bounds];
    BlackTitlebarView *titleview = [[BlackTitlebarView alloc] initWithFrame:boundsRect];
    [titleview setAutoresizingMask:(NSViewWidthSizable | NSViewHeightSizable)];
    
    [[[window contentView] superview] addSubview:titleview positioned:NSWindowBelow relativeTo:[[[[window contentView] superview] subviews] objectAtIndex:0]];
    
    
    
    chameleonApp = [[ChameleonAppDelegate alloc] init];
    [chameleonNSView launchApplicationWithDelegate:chameleonApp afterDelay:1];
}

@end
