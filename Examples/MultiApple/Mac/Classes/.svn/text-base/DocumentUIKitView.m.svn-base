//
//  DocumentUIKitView.m
//  MacApple
//
//  Created by Craig Hockenberry on 3/27/11.
//  Copyright 2011 The Iconfactory. All rights reserved.
//

#import "DocumentUIKitView.h"

#import <UIKit/UIKit.h>

@implementation DocumentUIKitView

@synthesize viewController;

- (void)dealloc
{
    [viewController release], viewController = nil;

    [super dealloc];
}

- (void)setViewController:(UIViewController *)newViewController
{
    if (newViewController != viewController) {
        [viewController.view removeFromSuperview];
        
        [viewController release];
        viewController = [newViewController retain];

        if (viewController) {
            viewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            viewController.view.frame = self.UIWindow.bounds;
            [self.UIWindow addSubview:viewController.view];
        }
    }
}

@end
