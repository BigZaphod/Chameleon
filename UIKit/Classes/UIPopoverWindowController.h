//
//  PopoverWindowController.h
//  Ostrich
//
//  Created by Craig Hockenberry on 7/26/10.
//  Copyright 2010 The Iconfactory. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class UIPopoverWindow, UIPopoverController;

@interface UIPopoverWindowController : NSWindowController <NSWindowDelegate>
{
	__weak UIPopoverController *popoverController;
}

- (id)initWithPopoverWindow:(UIPopoverWindow *)popoverWindow controller:(UIPopoverController *)controller;

@end
