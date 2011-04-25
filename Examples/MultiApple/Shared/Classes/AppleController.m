//
//  MacAppleController.m
//  MacApple & iOSApple
//
//  Created by Craig Hockenberry on 3/27/11.
//  Copyright 2011 The Iconfactory. All rights reserved.
//

#import "AppleController.h"

@interface AppleController ()

@property (nonatomic, retain) MyUIViewController *myUiViewController;

@end


@implementation AppleController

@synthesize delegate;
@synthesize myUiViewController;

- (id)init
{
    if ((self=[super init])) {
        // In this example, both the Mac and iOS versions of the product use the same view controller. If
        // you want to use different controllers that are specific to a platform, just move the instance
        // variable and instantiation to a subclass. The same goes with delegation. The thing you won't want
        // to mess with are the actions and state management: they work best when centralized in this base
        // class.
        myUiViewController = [[MyUIViewController alloc] init];
        myUiViewController.delegate = self;
    }
    return self;
}

- (void)dealloc
{
    myUiViewController.delegate = nil;
    [myUiViewController	release], myUiViewController = nil;

    [super dealloc];
}


// return the view controller that acts as the root for the application

- (UIViewController *)viewController
{
    // override in subclass
    return nil;
}


// forward delegate callbacks from the view controller

- (void)myUiViewControllerWillStartMovingApple:(MyUIViewController *)viewController
{
    // subclasses can override
    if ([delegate respondsToSelector:@selector(appleControllerWillStartMovingApple:)]) {
        [delegate appleControllerWillStartMovingApple:self];
    }
}

- (void)myUiViewControllerDidFinishMovingApple:(MyUIViewController *)viewController
{
    // subclasses can override
    if ([delegate respondsToSelector:@selector(appleControllerDidFinishMovingApple:)]) {
        [delegate appleControllerDidFinishMovingApple:self];
    }
}


// pass actions and state queries to the view controller

- (BOOL)canMoveApple
{
    return (! [myUiViewController isAppleMoving]);
}

- (void)moveTheApple
{
    [myUiViewController moveTheApple:self];
}

@end
