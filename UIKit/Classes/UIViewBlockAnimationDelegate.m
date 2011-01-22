//  Created by Sean Heber on 1/18/11.
#import "UIViewBlockAnimationDelegate.h"
#import "UIApplication.h"

@implementation UIViewBlockAnimationDelegate
@synthesize completion=_completion, ignoreInteractionEvents=_ignoreInteractionEvents;

- (void)dealloc
{
	[_completion release];
	[super dealloc];
}

- (void)animationDidStop:(NSString *)animationID finished:(NSNumber *)finished
{
	if (_completion) {
		_completion([finished boolValue]);
	}
	
	if (_ignoreInteractionEvents) {
		[[UIApplication sharedApplication] endIgnoringInteractionEvents];
	}	
}

@end
