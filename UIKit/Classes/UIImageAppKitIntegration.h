//  Created by Sean Heber on 10/12/10.
#import "UIImage.h"

@class NSImage;

@interface UIImage (AppKitIntegration)
- (id)initWithNSImage:(NSImage *)theImage;
- (NSImage *)NSImage;
@end
