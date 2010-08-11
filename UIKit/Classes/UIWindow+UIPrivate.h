//  Created by Sean Heber on 8/11/10.
#import "UIWindow.h"

@interface UIWindow (UIPrivate)
- (UIResponder *)_firstResponder;
- (void)_setFirstResponder:(UIResponder *)newFirstResponder;
- (void)_makeHidden;
- (void)_makeVisible;
@end
