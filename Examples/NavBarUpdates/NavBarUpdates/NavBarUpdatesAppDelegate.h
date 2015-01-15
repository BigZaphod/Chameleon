#import <Cocoa/Cocoa.h>
#import <UIKit/UIKit.h>
#import "MyWindow.h"


@class ChameleonAppDelegate;

@interface NavBarUpdatesAppDelegate : NSObject <NSApplicationDelegate> {
    ChameleonAppDelegate *chameleonApp;
}

@property (assign) IBOutlet MyWindow *window;
@property (assign) IBOutlet UIKitView *chameleonNSView;

@end
