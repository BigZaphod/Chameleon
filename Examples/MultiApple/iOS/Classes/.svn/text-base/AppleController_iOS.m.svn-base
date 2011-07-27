//
//  AppleController_iOS.m
//  iOSApple
//
//  Created by Craig Hockenberry on 3/27/11.
//  Copyright 2011 The Iconfactory. All rights reserved.
//

#import "AppleController_iOS.h"


@interface AppleController_iOS ()

@property (nonatomic, retain) UINavigationController *navigationController;

@end


@implementation AppleController_iOS

@synthesize navigationController;

- (id)init
{
    if ((self=[super init])) {
        navigationController = [[UINavigationController alloc] initWithRootViewController:myUiViewController];
        myUiViewController.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"Move" style:UIBarButtonItemStylePlain target:self action:@selector(moveTheApple)] autorelease];
    }
    return self;
}

- (void)dealloc
{
    [navigationController release], navigationController = nil;

    [super dealloc];
}

- (UIViewController *)viewController
{
    // the navigation controller's view is added to the UIWindow
    return navigationController;
}

- (void)myUiViewControllerWillStartMovingApple:(MyUIViewController *)viewController
{
    [myUiViewController.navigationItem.rightBarButtonItem setEnabled:NO];
}

- (void)myUiViewControllerDidFinishMovingApple:(MyUIViewController *)viewController
{
    [myUiViewController.navigationItem.rightBarButtonItem setEnabled:YES];
}

@end
