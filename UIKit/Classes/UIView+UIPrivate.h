//  Created by Sean Heber on 8/11/10.
#import "UIView.h"

@interface UIView (UIPrivate)
- (void)_layoutSubviews;
- (void)_setViewController:(UIViewController *)theViewController;
- (void)_superviewSizeDidChangeFrom:(CGSize)oldSize to:(CGSize)newSize;
- (void)_boundsSizeDidChange;
- (void)_hierarchyPositionDidChange;
@end
