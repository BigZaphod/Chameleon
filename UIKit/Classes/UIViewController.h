//  Created by Sean Heber on 6/25/10.
#import "UIResponder.h"
#import "UIApplication.h"

typedef enum {
	UIModalPresentationFullScreen = 0,
	UIModalPresentationPageSheet,
	UIModalPresentationFormSheet,
	UIModalPresentationCurrentContext,
} UIModalPresentationStyle;

typedef enum {
	UIModalTransitionStyleCoverVertical = 0,
	UIModalTransitionStyleFlipHorizontal,
	UIModalTransitionStyleCrossDissolve,
	UIModalTransitionStylePartialCurl,
} UIModalTransitionStyle;

@class UINavigationItem, UINavigationController, UIBarButtonItem, UISplitViewController;

@interface UIViewController : UIResponder {
@private
	UIView *_view;
	BOOL _wantsFullScreenLayout;
	NSString *_title;
	CGSize _contentSizeForViewInPopover;
	BOOL _modalInPopover;
	UINavigationItem *_navigationItem;
	NSArray *_toolbarItems;
	UIModalPresentationStyle _modalPresentationStyle;
	BOOL _editing;
	UINavigationController *_navigationController;
	UIViewController *_modalViewController;
	UIViewController *_parentViewController;
	UIModalTransitionStyle _modalTransitionStyle;
}

- (id)initWithNibName:(NSString *)nibName bundle:(NSBundle *)nibBundle;	// won't load a nib no matter what you do!

- (BOOL)isViewLoaded;
- (void)loadView;
- (void)viewDidLoad;
- (void)viewDidUnload;

- (void)viewWillAppear:(BOOL)animated;
- (void)viewDidAppear:(BOOL)animated;
- (void)viewWillDisappear:(BOOL)animated;
- (void)viewDidDisappear:(BOOL)animated;

- (void)presentModalViewController:(UIViewController *)modalViewController animated:(BOOL)animated;		// works, but not exactly correctly.
- (void)dismissModalViewControllerAnimated:(BOOL)animated;												// see comments in dismissModalViewController

- (void)didReceiveMemoryWarning;	// doesn't do anything at all right.

- (void)setToolbarItems:(NSArray *)toolbarItems animated:(BOOL)animated;
- (void)setEditing:(BOOL)editing animated:(BOOL)animated;
- (UIBarButtonItem *)editButtonItem;	// not implemented

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation;
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration;


@property (nonatomic, readonly, copy) NSString *nibName;		// always returns nil
@property (nonatomic, readonly, retain) NSBundle *nibBundle;	// always returns nil
@property (nonatomic, retain) UIView *view;
@property (nonatomic, assign) BOOL wantsFullScreenLayout;		// doesn't do anything right now
@property (nonatomic, copy) NSString *title;
@property (nonatomic, readwrite) CGSize contentSizeForViewInPopover;
@property (nonatomic,readwrite,getter=isModalInPopover) BOOL modalInPopover;
@property (nonatomic, assign) UIModalTransitionStyle modalTransitionStyle;		// not used right now
@property (nonatomic, readonly) UIInterfaceOrientation interfaceOrientation;	// always returns UIInterfaceOrientationLandscapeLeft
@property (nonatomic, readonly, retain) UINavigationItem *navigationItem;
@property (nonatomic, readonly, retain) UINavigationController *navigationController;
@property (nonatomic, readonly) UIViewController *parentViewController;
@property (nonatomic, retain) NSArray *toolbarItems;
@property (nonatomic, assign) UIModalPresentationStyle modalPresentationStyle;
@property (nonatomic, getter=isEditing) BOOL editing;
@property (nonatomic, readonly) UIViewController *modalViewController;
@property (nonatomic, readonly, retain) UISplitViewController *splitViewController;		// currently returns nil

@end
