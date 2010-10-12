//  Created by Sean Heber on 10/12/10.
#import "UIColor.h"

@class NSColor;

@interface UIColor (AppKitIntegration)
- (id)initWithNSColor:(NSColor *)c;
- (NSColor *)NSColor;						// NOTE: At present, if the UIColor was created with an image, this is unlikely to work.
@end
