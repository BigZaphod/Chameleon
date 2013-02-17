//
//  FDAppDelegate.h
//  IOSandMac_NoXib
//
//  Created by Dominik Pich on 07.02.13.
//  Copyright (c) 2013 Dominik Pich. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FDMainViewController;

@interface FDAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) FDMainViewController *mainViewController;

@end
