//
//  AppleController.h
//  MacApple & iOSApple
//
//  Created by Craig Hockenberry on 3/27/11.
//  Copyright 2011 The Iconfactory. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MyUIViewController.h"

@class AppleController;

@protocol AppleControllerDelegate <NSObject>

@optional

- (void)appleControllerWillStartMovingApple:(AppleController *)controller;
- (void)appleControllerDidFinishMovingApple:(AppleController *)controller;

@end

@interface AppleController : NSObject <MyUIViewControllerDelegate>
{
    id<AppleControllerDelegate> delegate;
    MyUIViewController *myUiViewController;
}

@property (nonatomic, assign) id<AppleControllerDelegate> delegate;

- (UIViewController *)viewController;

- (BOOL)canMoveApple;
- (void)moveTheApple;

@end

