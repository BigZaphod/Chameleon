//  Created by Sean Heber on 6/19/10
#import "_UIImageTools.h"
#import <AppKit/AppKit.h>

NSImage *_NSImageCreateSubimage(NSImage *theImage, CGRect rect)
{
	// flip coordinates around...
	rect.origin.y = (theImage.size.height) - rect.size.height - rect.origin.y;
	NSImage *destinationImage = [[NSImage alloc] initWithSize:NSSizeFromCGSize(rect.size)];
	[destinationImage lockFocus];
	[theImage drawAtPoint:NSZeroPoint fromRect:NSRectFromCGRect(rect) operation:NSCompositeCopy fraction:1];
	[destinationImage unlockFocus];
	return destinationImage;
}

NSCompositingOperation _NSCompositingOperationFromCGBlendMode(CGBlendMode blendMode) {
	switch (blendMode) {
		case kCGBlendModeNormal:
		case kCGBlendModeMultiply:			
		case kCGBlendModeScreen:
		case kCGBlendModeOverlay:
		case kCGBlendModeDarken:
		case kCGBlendModeLighten:
		case kCGBlendModeColorDodge:
		case kCGBlendModeColorBurn:
		case kCGBlendModeSoftLight:
		case kCGBlendModeHardLight:
		case kCGBlendModeDifference:
		case kCGBlendModeExclusion:
		case kCGBlendModeHue:
		case kCGBlendModeSaturation:
		case kCGBlendModeColor:
		case kCGBlendModeLuminosity:
		case kCGBlendModeClear:
		case kCGBlendModeCopy:
		case kCGBlendModeSourceIn:
		case kCGBlendModeSourceOut:
		case kCGBlendModeSourceAtop:
		case kCGBlendModeDestinationOver:
		case kCGBlendModeDestinationIn:
		case kCGBlendModeDestinationOut:
		case kCGBlendModeDestinationAtop:
		case kCGBlendModeXOR:
		case kCGBlendModePlusDarker:
		case kCGBlendModePlusLighter:
		default:
			return NSCompositeCopy;
	}
}
