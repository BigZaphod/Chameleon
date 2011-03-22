//  Created by Sean Heber on 1/13/11.
#import <Cocoa/Cocoa.h>
#import <UIKit/UIKitView.h>

@class ChameleonAppDelegate;

@interface BigAppleAppDelegate : NSObject <NSApplicationDelegate> {
    NSWindow *window;
	UIKitView *chameleonNSView;
	ChameleonAppDelegate *chameleonApp;
}

@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet UIKitView *chameleonNSView;

@end
