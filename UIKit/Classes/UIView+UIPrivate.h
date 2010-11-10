//  Created by Sean Heber on 8/11/10.
#import "UIView.h"

extern NSString *const UIViewFrameDidChangeNotification;
extern NSString *const UIViewBoundsDidChangeNotification;
extern NSString *const UIViewDidMoveToSuperviewNotification;

@interface UIView (UIPrivate)
- (void)_removeFromSuperview:(BOOL)notifyViewController;
- (void)_setViewController:(UIViewController *)theViewController;
- (void)_superviewSizeDidChangeFrom:(CGSize)oldSize to:(CGSize)newSize;
@end
