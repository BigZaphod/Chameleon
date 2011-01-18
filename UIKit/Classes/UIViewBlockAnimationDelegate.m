//  Created by Sean Heber on 1/18/11.
#import "UIViewBlockAnimationDelegate.h"
#import "UIApplication.h"

@implementation UIViewBlockAnimationDelegate
@synthesize completion=_completion, interactionEventsAllowed=_interactionEventsAllowed;

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
	
	if (!_interactionEventsAllowed) {
		[[UIApplication sharedApplication] endIgnoringInteractionEvents];
	}	
}

@end
