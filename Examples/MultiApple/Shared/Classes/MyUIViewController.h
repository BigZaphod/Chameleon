//
//  MyUIViewController.h
//  MacApple & iOSApple
//
//  Created by Craig Hockenberry on 3/27/11.
//  Copyright 2011 The Iconfactory. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MyUIViewController;

@protocol MyUIViewControllerDelegate <NSObject>

@optional

- (void)myUiViewControllerWillStartMovingApple:(MyUIViewController *)viewController;
- (void)myUiViewControllerDidFinishMovingApple:(MyUIViewController *)viewController;

@end

@interface MyUIViewController : UIViewController
{
    id<MyUIViewControllerDelegate> delegate;
    UIImageView *appleView;
    UIButton *sillyButton;
    BOOL appleMoving;
}

@property (nonatomic, retain) UIImageView *appleView;
@property (nonatomic, retain) UIButton *sillyButton;

@property (nonatomic, assign) id<MyUIViewControllerDelegate> delegate;
@property (nonatomic, readonly, assign, getter=isAppleMoving) BOOL appleMoving;

- (void)moveTheApple:(id)sender;

@end
