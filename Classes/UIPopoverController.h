//  Created by Sean Heber on 6/25/10.
#import <Foundation/Foundation.h>

enum {
	UIPopoverArrowDirectionUp = 1UL << 0,
	UIPopoverArrowDirectionDown = 1UL << 1,
	UIPopoverArrowDirectionLeft = 1UL << 2,
	UIPopoverArrowDirectionRight = 1UL << 3,
	UIPopoverArrowDirectionAny = UIPopoverArrowDirectionUp | UIPopoverArrowDirectionDown |
	UIPopoverArrowDirectionLeft | UIPopoverArrowDirectionRight,
	UIPopoverArrowDirectionUnknown = NSUIntegerMax
};
typedef NSUInteger UIPopoverArrowDirection;

@class UIView, UIViewController, UIPopoverController;

@protocol UIPopoverControllerDelegate <NSObject>
@optional
- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController;
- (BOOL)popoverControllerShouldDismissPopover:(UIPopoverController *)popoverController;
@end

@interface UIPopoverController : NSObject {
@private
	id _delegate;
	UIViewController *_contentViewController;
	BOOL _popoverVisible;
}

- (id)initWithContentViewController:(UIViewController *)viewController;

- (void)presentPopoverFromRect:(CGRect)rect inView:(UIView *)view permittedArrowDirections:(UIPopoverArrowDirection)arrowDirections animated:(BOOL)animated;
- (void)dismissPopoverAnimated:(BOOL)animated;

@property (nonatomic, assign) id <UIPopoverControllerDelegate> delegate;
@property (nonatomic, retain) UIViewController *contentViewController;
@property (nonatomic, readonly, getter=isPopoverVisible) BOOL popoverVisible;

@end
