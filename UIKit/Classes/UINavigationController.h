//  Created by Sean Heber on 6/25/10.
#import "UIViewController.h"

@class UINavigationBar, UIToolbar, UIViewController;

@protocol UINavigationControllerDelegate <NSObject>
@optional
- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated;
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated;
@end

@interface UINavigationController : UIViewController {
@private
	UINavigationBar *_navigationBar;
	UIToolbar *_toolbar;
	NSMutableArray *_viewControllers;
	id _delegate;
	BOOL _toolbarHidden;
	
	struct {
		BOOL didShowViewController : 1;
		BOOL willShowViewController : 1;
	} _delegateHas;
}

- (id)initWithRootViewController:(UIViewController *)rootViewController;

- (void)setViewControllers:(NSArray *)newViewControllers animated:(BOOL)animated;

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated;
- (UIViewController *)popViewControllerAnimated:(BOOL)animated;
- (NSArray *)popToViewController:(UIViewController *)viewController animated:(BOOL)animated;
- (NSArray *)popToRootViewControllerAnimated:(BOOL)animated;

- (void)setToolbarHidden:(BOOL)hidden animated:(BOOL)animated;

@property (nonatomic, copy) NSArray *viewControllers;
@property (nonatomic, readonly) UINavigationBar *navigationBar;
@property (nonatomic, readonly) UIToolbar *toolbar;
@property (nonatomic, assign) id<UINavigationControllerDelegate> delegate;
@property (nonatomic, readonly, retain) UIViewController *topViewController;
@property (nonatomic,getter=isToolbarHidden) BOOL toolbarHidden;

@end
