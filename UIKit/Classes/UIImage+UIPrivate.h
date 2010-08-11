//  Created by Sean Heber on 8/11/10.
#import "UIImage.h"

@class NSImage;

@interface UIImage (UIPrivate)
+ (UIImage *)_frameworkImageNamed:(NSString *)name;
- (id)_initWithNSImage:(NSImage *)theImage;
@end
