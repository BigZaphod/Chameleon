//  Created by Sean Heber on 1/13/11.
#import "ChameleonAppDelegate.h"

@implementation ChameleonAppDelegate

- (void)applicationDidFinishLaunching:(UIApplication *)application
{
	window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].applicationFrame];
	window.backgroundColor = [UIColor whiteColor];
	window.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

	
	appleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"apple.png"]];
	[window addSubview:appleView];


	sillyButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	[sillyButton setTitle:@"Click Me!" forState:UIControlStateNormal];
	[sillyButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	[sillyButton addTarget:self action:@selector(moveTheApple:) forControlEvents:UIControlEventTouchUpInside];
	sillyButton.frame = CGRectMake(22,300,200,50);
	[window addSubview:sillyButton];
	
	
	[window makeKeyAndVisible];
}

- (void)dealloc
{
	[window release];
	[super dealloc];
}

- (void)moveTheApple:(id)sender
{
	[UIView beginAnimations:@"moveTheApple" context:nil];
	[UIView setAnimationDuration:3];
	[UIView setAnimationBeginsFromCurrentState:YES];

	if (CGAffineTransformIsIdentity(appleView.transform)) {
		appleView.transform = CGAffineTransformMakeScale(0.5, 0.5);
		appleView.center = [window convertPoint:window.center toView:appleView.superview];
	} else {
		appleView.transform = CGAffineTransformIdentity;
		appleView.frame = CGRectMake(0,0,256,256);
	}
	
	[UIView commitAnimations];
}

@end
