//
//  NavBarUpdatesAppDelegate.h
//  NavBarUpdates
//
//  Created by Jim Dovey on 11-03-22.
//  Copyright 2011 XPlatform Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <UIKit/UIKit.h>

@class ChameleonAppDelegate;

@interface NavBarUpdatesAppDelegate : NSObject <NSApplicationDelegate> {
@private
    NSWindow *window;
    UIKitView *chameleonNSView;
    ChameleonAppDelegate *chameleonApp;
}

@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet UIKitView *chameleonNSView;

@end
