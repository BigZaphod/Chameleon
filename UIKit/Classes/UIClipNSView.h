//  Created by Sean Heber on 8/23/10.
#import <AppKit/NSClipView.h>

@class UIView;

@interface UIClipNSView : NSClipView {
	__weak UIView *containerView;
}
- (void)setContainerView:(UIView *)view;
@end
