//
//  FDAppDelegate.m
//  IOSandMac_NoXib
//
//  Created by Dominik Pich on 07.02.13.
//  Copyright (c) 2013 Dominik Pich. All rights reserved.
//

#import "FDAppDelegate.h"
#import "FDMainViewController.h"

@implementation FDAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.mainViewController = [[FDMainViewController alloc] init];
    self.window.rootViewController = self.mainViewController;
    self.window.backgroundColor = [UIColor blackColor];
    [self.window makeKeyAndVisible];
    return YES;
}

@end
