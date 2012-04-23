//
//  MPMediaPickerControllerDelegate.h
//  FlickStackr
//
//  Created by Carlos Mejía on 11-11-16.
//  Copyright (c) 2011 iPont. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MPMediaPickerController.h"

@implementation MPMediaPickerController 
@synthesize mediaTypes;
@synthesize delegate;
@synthesize allowsPickingMultipleItems;
@synthesize prompt;
- (id)init
{
    return (self = [super init]);
}
- (id)initWithMediaTypes:(MPMediaType)mediaTypes
{
    return (self = [super init]);
}
@end