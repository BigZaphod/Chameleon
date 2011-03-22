//  Created by Sean Heber on 1/13/11.
#import "BigAppleAppDelegate.h"
#import "ChameleonAppDelegate.h"

@implementation BigAppleAppDelegate
@synthesize window, chameleonNSView;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	chameleonApp = [[ChameleonAppDelegate alloc] init];
	[chameleonNSView launchApplicationWithDelegate:chameleonApp afterDelay:1];
}

- (void)dealloc
{
	[chameleonApp release];
	[super dealloc];
}

@end
