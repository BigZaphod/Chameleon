//
//  MyDocument.m
//  MacApple
//
//  Created by Craig Hockenberry on 3/27/11.
//  Copyright 2011 The Iconfactory. All rights reserved.
//

#import "MyDocument.h"

#import "AppleController_Mac.h"
#import "DocumentUIKitView.h"


@interface MyDocument ()

@property (nonatomic, retain) AppleController_Mac *appleController;

@end


@implementation MyDocument

@synthesize toolbar;
@synthesize progressIndicator;
@synthesize documentUiKitView;

@synthesize appleController;

- (id)init
{
    self = [super init];
    if (self) {
        appleController = [[AppleController_Mac alloc] init];
        appleController.delegate = self;
    }
    return self;
}

- (void)dealloc
{
    [appleController release], appleController = nil;

    [super dealloc];
}

- (void)windowControllerDidLoadNib:(NSWindowController *) aController
{
    [super windowControllerDidLoadNib:aController];

    // once the UIKitView is loaded, give it a view controller
    documentUiKitView.viewController = appleController.viewController;
}


// use the application controller to validate menu and toolbar items

- (BOOL)validateMenuItem:(NSMenuItem *)item
{
    if ([item action] == @selector(moveTheApple:)) {
        // disable the menu item while the controller is moving the apple
        return [appleController canMoveApple];
    }

    return YES;
}

- (BOOL)validateToolbarItem:(NSToolbarItem *)toolbarItem
{
    if ([toolbarItem action] == @selector(moveTheApple:)) {
        // disable the toolbar item while the controller is moving the apple
        return [appleController canMoveApple];
    }

    return NO;
}


// forward the action coming from the menu and toolbar to the application controller

- (IBAction)moveTheApple:(id)sender
{
    [appleController moveTheApple];
    [toolbar validateVisibleItems];
}


// handle the application controller callbacks to update the user interface

- (void)appleControllerWillStartMovingApple:(AppleController *)controller
{
    NSLog(@"apple will start moving");
    [toolbar validateVisibleItems];
    [progressIndicator startAnimation:self];
}

- (void)appleControllerDidFinishMovingApple:(AppleController *)controller
{
    NSLog(@"apple did finish moving");
    [progressIndicator stopAnimation:self];
    [toolbar validateVisibleItems];
}


// the rest of this code is just standard document handling from the Xcode template

- (NSString *)windowNibName
{
    // Override returning the nib file name of the document
    // If you need to use a subclass of NSWindowController or if your document supports multiple NSWindowControllers, you should remove this method and override -makeWindowControllers instead.
    return @"MyDocument";
}

- (NSData *)dataOfType:(NSString *)typeName error:(NSError **)outError
{
    // Insert code here to write your document to data of the specified type. If the given outError != NULL, ensure that you set *outError when returning nil.

    // You can also choose to override -fileWrapperOfType:error:, -writeToURL:ofType:error:, or -writeToURL:ofType:forSaveOperation:originalContentsURL:error: instead.

    // For applications targeted for Panther or earlier systems, you should use the deprecated API -dataRepresentationOfType:. In this case you can also choose to override -fileWrapperRepresentationOfType: or -writeToFile:ofType: instead.

    if ( outError != NULL ) {
        *outError = [NSError errorWithDomain:NSOSStatusErrorDomain code:unimpErr userInfo:NULL];
    }
    return nil;
}

- (BOOL)readFromData:(NSData *)data ofType:(NSString *)typeName error:(NSError **)outError
{
    // Insert code here to read your document from the given data of the specified type.  If the given outError != NULL, ensure that you set *outError when returning NO.

    // You can also choose to override -readFromFileWrapper:ofType:error: or -readFromURL:ofType:error: instead. 
    
    // For applications targeted for Panther or earlier systems, you should use the deprecated API -loadDataRepresentation:ofType. In this case you can also choose to override -readFromFile:ofType: or -loadFileWrapperRepresentation:ofType: instead.
    
    if ( outError != NULL ) {
        *outError = [NSError errorWithDomain:NSOSStatusErrorDomain code:unimpErr userInfo:NULL];
    }
    return YES;
}

@end
