//  Created by Sean Heber on 8/11/10.
#import "UIImageView.h"

enum {
	_UIImageViewDrawModeNormal,
	_UIImageViewDrawModeHighlighted,
	_UIImageViewDrawModeDisabled,
};

@interface UIImageView (UIPrivate)
- (void)_setDrawMode:(NSInteger)drawMode;
@end
