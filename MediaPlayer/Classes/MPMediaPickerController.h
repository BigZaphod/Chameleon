//
//  MPMediaPickerControllerDelegate.h
//  FlickStackr
//
//  Created by Carlos Mejía on 11-11-16.
//  Copyright (c) 2011 iPont. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIViewController.h>
#import "MPMediaEntity.h"
@class MPMediaPickerController;
@class MPMediaItemCollection;
@protocol MPMediaPickerControllerDelegate<NSObject>
@optional

// It is the delegate's responsibility to dismiss the modal view controller on the parent view controller.

- (void)mediaPicker:(MPMediaPickerController *)mediaPicker didPickMediaItems:(MPMediaItemCollection *)mediaItemCollection;
- (void)mediaPickerDidCancel:(MPMediaPickerController *)mediaPicker;

@end

@interface MPMediaPickerController : UIViewController 
{
}

- (id)init; // defaults to MPMediaTypeAny
- (id)initWithMediaTypes:(MPMediaType)mediaTypes;
@property(nonatomic, readonly) MPMediaType mediaTypes;

@property(nonatomic, assign) id<MPMediaPickerControllerDelegate> delegate;

@property(nonatomic) BOOL allowsPickingMultipleItems; // default is NO

@property(nonatomic, copy) NSString *prompt; // displays a prompt for the user above the navigation bar buttons

@end