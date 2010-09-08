//  Created by Sean Heber on 7/22/10.
#import "UIViewController.h"

@protocol UISplitViewControllerDelegate;

@interface UISplitViewController : UIViewController {
@private
	id <UISplitViewControllerDelegate> _delegate;
	NSArray *_viewControllers;
	
	struct {
		unsigned int willPresentViewController : 1;
		unsigned int willHideViewController : 1;
		unsigned int willShowViewController : 1;
	} _delegateHas;
}

@property (nonatomic, assign) id <UISplitViewControllerDelegate> delegate;
@property (nonatomic, copy) NSArray *viewControllers;

@end

@class UIPopoverController;

@protocol UISplitViewControllerDelegate <NSObject>
@optional
- (void)splitViewController:(UISplitViewController*)svc popoverController:(UIPopoverController*)pc willPresentViewController:(UIViewController *)aViewController;
- (void)splitViewController:(UISplitViewController*)svc willHideViewController:(UIViewController *)aViewController withBarButtonItem:(UIBarButtonItem*)barButtonItem forPopoverController:(UIPopoverController*)pc;
- (void)splitViewController:(UISplitViewController*)svc willShowViewController:(UIViewController *)aViewController invalidatingBarButtonItem:(UIBarButtonItem *)button;
@end
