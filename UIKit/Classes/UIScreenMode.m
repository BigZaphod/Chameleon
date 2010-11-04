//  Created by Sean Heber on 6/25/10.
#import "UIScreenMode.h"
#import <AppKit/AppKit.h>

@implementation UIScreenMode
@synthesize pixelAspectRatio=_pixelAspectRatio, size=_size;

+ (id)screenModeWithNSView:(NSView *)theNSView
{
	UIScreenMode *mode = [[self alloc] init];
	mode->_size = NSSizeToCGSize([theNSView bounds].size);
	mode->_pixelAspectRatio = 1;
	return [mode autorelease];
}

@end
