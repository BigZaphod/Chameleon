#import <UIKit/UIView.h>


@interface UIView (AppKitIntegration)

- (void) setNextKeyView:(UIView*)view;
- (UIView*) nextKeyView;
- (UIView*) previousKeyView;
- (UIView*) nextValidKeyView;
- (UIView*) previousValidKeyView;

@end
