//  Created by Sean Heber on 10/12/10.
#import "UIImage.h"

@class NSImage;

@interface UIImage (UIAppKitIntegration)
- (id)initWithNSImage:(NSImage *)theImage;
- (NSImage *)NSImage;
@end
