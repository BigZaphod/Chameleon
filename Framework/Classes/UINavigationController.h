//  Created by Sean Heber on 6/25/10.
#import "UIViewController.h"

@class UINavigationBar, UIToolbar;

@protocol UINavigationControllerDelegate <NSObject>
@end

@interface UINavigationController : UIViewController {
@private
	NSArray *_viewControllers;
	id _delegate;
}

- (id)initWithRootViewController:(UIViewController *)rootViewController;

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated;
- (UIViewController *)popViewControllerAnimated:(BOOL)animated;
- (NSArray *)popToViewController:(UIViewController *)viewController animated:(BOOL)animated;
- (NSArray *)popToRootViewControllerAnimated:(BOOL)animated;

- (void)setToolbarHidden:(BOOL)hidden animated:(BOOL)animated;

@property (nonatomic, copy) NSArray *viewControllers;
@property (nonatomic, readonly) UINavigationBar *navigationBar;
@property (nonatomic, readonly) UIToolbar *toolbar;
@property (nonatomic, assign) id<UINavigationControllerDelegate> delegate;

@end
