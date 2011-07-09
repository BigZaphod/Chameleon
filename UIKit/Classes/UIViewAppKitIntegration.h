#import <UIKit/UIView.h>


@interface UIView () 
@property (nonatomic, copy) NSString *toolTip;
@end


@interface UIView (AppKitIntegration)
- (void) setNextKeyView:(UIView*)view;
- (UIView*) nextKeyView;
- (UIView*) previousKeyView;
- (UIView*) nextValidKeyView;
- (UIView*) previousValidKeyView;
@end
