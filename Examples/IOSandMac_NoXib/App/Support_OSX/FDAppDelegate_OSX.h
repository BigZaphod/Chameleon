//
//  FDAppDelegate_OSX.h
//  IOSandMac_NoXib
//
//  Created by Dominik Pich on 11.02.13.
//  Copyright (c) 2013 Dominik Pich. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <UIKit/UIKitView.h>
#import "FDAppDelegate.h"

@interface FDAppDelegate_OSX : NSObject<NSApplicationDelegate>

@property(nonatomic, retain) FDAppDelegate *appDelegate;
@property(nonatomic, retain) UIKitView *container;
@property(nonatomic, retain) NSWindow *window;
@property(nonatomic, retain) NSStatusItem *item;
@end
