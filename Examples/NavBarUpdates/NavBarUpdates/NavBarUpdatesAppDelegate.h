#import <Cocoa/Cocoa.h>
#import <UIKit/UIKit.h>
#import "WAYWindow.h"

@class ChameleonAppDelegate;

@interface NavBarUpdatesAppDelegate : NSObject <NSApplicationDelegate> {
    ChameleonAppDelegate *chameleonApp;
}

@property (assign) IBOutlet WAYWindow *window;
@property (assign) IBOutlet UIKitView *chameleonNSView;

@end
