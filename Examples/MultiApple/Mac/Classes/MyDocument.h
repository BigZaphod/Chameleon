//
//  MyDocument.h
//  MacApple
//
//  Created by Craig Hockenberry on 3/27/11.
//  Copyright 2011 The Iconfactory. All rights reserved.
//


#import <Cocoa/Cocoa.h>

#import <UIKit/UIKit.h>

#import "AppleController_Mac.h"

@class DocumentUIKitView;

@interface MyDocument : NSDocument <AppleControllerDelegate>
{
    NSToolbar *toolbar;
    NSProgressIndicator *progressIndicator;
    DocumentUIKitView *documentUiKitView;

    AppleController_Mac *appleController;
}

@property (assign) IBOutlet NSToolbar *toolbar;
@property (assign) IBOutlet NSProgressIndicator *progressIndicator;
@property (assign) IBOutlet DocumentUIKitView *documentUiKitView;

- (IBAction)moveTheApple:(id)sender;

@end
