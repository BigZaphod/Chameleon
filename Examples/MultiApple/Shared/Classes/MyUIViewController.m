//
//  MyUIViewController.m
//  MacApple & iOSApple
//
//  Created by Craig Hockenberry on 3/27/11.
//  Copyright 2011 The Iconfactory. All rights reserved.
//

#import "MyUIViewController.h"


// There are times when definitions don't match between iOS and the Mac. Examples are UTI type definitions
// and security keychain functions. In these cases, the TARGET_OS_IPHONE preprocessor definition can be used
// to select the right code for the appropriate platform.
#if TARGET_OS_IPHONE
//	#import <MobileCoreServices/MobileCoreServices.h>
#else
//	#import <CoreServices/CoreServices.h>
#endif


@interface MyUIViewController ()

@property (nonatomic, readwrite, assign, getter=isAppleMoving) BOOL appleMoving;

@end

@implementation MyUIViewController

@synthesize appleView;
@synthesize sillyButton;

@synthesize delegate;
@synthesize appleMoving;

- (void)loadView
{
    self.view = [[[UIView alloc] initWithFrame:CGRectMake(0,0,320,460)] autorelease];

    self.view.backgroundColor = [UIColor whiteColor];
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

    appleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"apple.png"]];
    [self.view addSubview:appleView];

    sillyButton = [[UIButton buttonWithType:UIButtonTypeRoundedRect] retain];
// FIXME: The title is wrong on the button. Remove the exclamation point!!!!!!11!!
    [sillyButton setTitle:@"Click Me!" forState:UIControlStateNormal];
// .. and then realize you're updating both the Mac and iOS versions of your products at once.
// HUGE WHEN LIKE THE CHOCK

    // Use the user interface idiom to customize the views based upon the platform. In this case it's simply the
    // color of a UI element, but the size and placement of elements will also need to be changed.
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone || UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [sillyButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    }
    else {
        [sillyButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }

    [sillyButton addTarget:self action:@selector(moveTheApple:) forControlEvents:UIControlEventTouchUpInside];
    sillyButton.frame = CGRectMake(22,300,200,50);
    sillyButton.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    [self.view addSubview:sillyButton];
}

- (void)viewDidUnload
{
    [appleView release], appleView = nil;
    [sillyButton release], sillyButton = nil;

    [super viewDidUnload];
}

- (void)dealloc
{
    [appleView release], appleView = nil;
    [sillyButton release], sillyButton = nil;
    
    [super dealloc];
}

- (void)appleMoveDidFinish
{
    self.appleMoving = NO;

    if ([delegate respondsToSelector:@selector(myUiViewControllerDidFinishMovingApple:)]) {
        [delegate myUiViewControllerDidFinishMovingApple:self];
    }
}

- (void)moveTheApple:(id)sender
{
    if ([delegate respondsToSelector:@selector(myUiViewControllerWillStartMovingApple:)]) {
        [delegate myUiViewControllerWillStartMovingApple:self];
    }
    
    [UIView beginAnimations:@"moveTheApple" context:nil];
    [UIView setAnimationDuration:3];
    [UIView setAnimationDidStopSelector:@selector(appleMoveDidFinish)];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationBeginsFromCurrentState:YES];

    if (CGAffineTransformIsIdentity(appleView.transform)) {
        appleView.transform = CGAffineTransformMakeScale(0.5, 0.5);
        appleView.center = [self.view convertPoint:self.view.center toView:appleView.superview];
    } else {
        appleView.transform = CGAffineTransformIdentity;
        appleView.frame = CGRectMake(0,0,256,256);
    }
    
    [UIView commitAnimations];
    
    self.appleMoving = YES;
}

@end
