//
//  FDAppDelegate_OSX.m
//  IOSandMac_NoXib
//
//  Created by Dominik Pich on 11.02.13.
//  Copyright (c) 2013 Dominik Pich. All rights reserved.
//

#import "FDAppDelegate_OSX.h"
#import "DDQuickMenuStatusItemView.h"

@implementation FDAppDelegate_OSX

- (void)applicationDidFinishLaunching:(NSNotification *)notification {
    self.window = [[NSWindow alloc] initWithContentRect:NSMakeRect(0, 0, 320, 480)
                                              styleMask:NSTitledWindowMask|NSClosableWindowMask
                                                backing:NSBackingStoreBuffered
                                                  defer:NO];
    
    self.window.title = @"Decision Maker";

    //prepare & launch UIKit
    self.appDelegate = [[FDAppDelegate alloc] init];
    self.container = [[UIKitView alloc] initWithFrame:NSMakeRect(0, 0, 320, 480)];
    [self.window.contentView addSubview:(id)self.container];
    [self.container launchApplicationWithDelegate:self.appDelegate afterDelay:0];

    //setup item
    self.item = [[NSStatusBar systemStatusBar] statusItemWithLength:NSSquareStatusItemLength];
    self.item.title = @"DM";
    
    //prepare menu for item
    NSMenu *menu = [[NSMenu alloc] init];
    NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:@"Open... (right click icon)" action:@selector(toggleMainWindow:) keyEquivalent:@""];
    item.target = self;
    [menu addItem:item];
    item = [[NSMenuItem alloc] initWithTitle:@"About..." action:@selector(showAboutWindow:) keyEquivalent:@""];
    item.target = self;
    [menu addItem:item];
    item = [[NSMenuItem alloc] initWithTitle:@"Quit" action:@selector(quitApp:) keyEquivalent:@""];
    item.target = self;
    [menu addItem:item];
    self.item.menu = menu;
    
    // setup custom view that implements mouseDown: and rightMouseDown:
    DDQuickMenuStatusItemView *view = [[DDQuickMenuStatusItemView alloc] init];
    view.item = self.item;
    view.title = self.item.title;
    view.target = self;
    view.action = @selector(itemClicked:);
    self.item.view = view;
}

#pragma mark - actions

- (IBAction)itemClicked:(NSStatusItem*)item {
    if(self.window.isVisible) {
        [self.window orderOut:nil];
        [NSApp deactivate];
    }
    else {
        [NSApp activateIgnoringOtherApps:YES];

        NSRect menuScreenFrame = [[NSScreen screens][0] visibleFrame];
        NSRect itemFrame = [self.item.view convertRect:self.item.view.frame toView:nil];
        itemFrame = [self.item.view.window convertRectToScreen:itemFrame];
        NSPoint ItemCenter = NSMakePoint(NSMidX(itemFrame), NSMaxY(menuScreenFrame));
        
        NSPoint windowOrigin = NSMakePoint(MIN(ItemCenter.x-self.window.frame.size.width/2, NSMaxX(menuScreenFrame)-self.window.frame.size.width), MIN(ItemCenter.y, NSMaxY(menuScreenFrame)));
        
        if(windowOrigin.x + self.window.frame.size.width/2 > menuScreenFrame.origin.x + menuScreenFrame.size.width)
            windowOrigin.x = menuScreenFrame.origin.x + menuScreenFrame.size.width - self.window.frame.size.width;
        
        [self.window setFrameTopLeftPoint:windowOrigin];
        [self.window setLevel:NSFloatingWindowLevel];
        [self.window makeKeyAndOrderFront:nil];
    }
    [(DDQuickMenuStatusItemView*)self.item.view setHighlighted:self.window.isVisible];
    [self.item.menu.itemArray[0] setTitle:!self.window.isVisible ? @"Open... (right click icon)" : @"Close (right click icon)"];
}

- (IBAction)toggleMainWindow:(id)sender {
    [self itemClicked:self.item];
}

- (IBAction)showAboutWindow:(id)sender {
    [NSApp activateIgnoringOtherApps:YES];
    [NSApp orderFrontStandardAboutPanel:nil];
}

- (IBAction)quitApp:(id)sender {
    [NSApp terminate:sender];
}

@end
