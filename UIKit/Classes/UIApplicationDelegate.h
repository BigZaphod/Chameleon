//  Created by Sean Heber on 8/11/10.
#import <Foundation/Foundation.h>

@class UIApplication;

@protocol UIApplicationDelegate <NSObject>
@optional
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions;
- (void)applicationDidFinishLaunching:(UIApplication *)application;
- (void)applicationDidBecomeActive:(UIApplication *)application;
@end
