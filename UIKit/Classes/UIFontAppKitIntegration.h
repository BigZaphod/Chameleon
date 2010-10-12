//  Created by Sean Heber on 10/12/10.
#import "UIFont.h"

@class NSFont;

@interface UIFont (UIAppKitIntegration)
+ (UIFont *)fontWithNSFont:(NSFont *)aFont;
- (NSFont *)NSFont;
@end
