//
//  DocumentUIKitView.h
//  MacApple
//
//  Created by Craig Hockenberry on 3/27/11.
//  Copyright 2011 The Iconfactory. All rights reserved.
//

#import <UIKit/UIKitView.h>

@class UIViewController;

@interface DocumentUIKitView : UIKitView
{
    UIViewController *viewController;
}

@property (nonatomic, retain) UIViewController *viewController;

@end
