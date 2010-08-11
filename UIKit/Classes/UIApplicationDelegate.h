//  Created by Sean Heber on 8/11/10.
#import <Foundation/Foundation.h>

@class UIApplication;

@protocol UIApplicationDelegate <NSObject>
@optional
- (void)applicationDidFinishLaunching:(UIApplication *)application;
@end
