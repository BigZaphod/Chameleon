//  Created by Sean Heber on 10/12/10.
#import "UIFont.h"

@class NSFont;

@interface UIFont (AppKitIntegration)
+ (UIFont *)fontWithNSFont:(NSFont *)aFont;
- (NSFont *)NSFont;

// these override the use of OSX's default system fonts, set to nil to use OSX default
+ (void)setSystemFontName:(NSString *)aName;
+ (void)setBoldSystemFontName:(NSString *)aName;
@end
