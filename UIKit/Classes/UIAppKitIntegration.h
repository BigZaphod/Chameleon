//  Created by Sean Heber on 10/12/10.
#import "UIImage.h"
#import "UIFont.h"
#import "UIColor.h"


@class NSImage, NSFont, NSColor;


@interface UIImage (UIAppKitIntegration)
- (id)initWithNSImage:(NSImage *)theImage;
- (NSImage *)NSImage;
@end


@interface UIFont (UIAppKitIntegration)
+ (UIFont *)fontWithNSFont:(NSFont *)aFont;
- (NSFont *)NSFont;
@end


@interface UIColor (UIAppKitIntegration)
- (id)initWithNSColor:(NSColor *)c;
- (NSColor *)NSColor;
@end
