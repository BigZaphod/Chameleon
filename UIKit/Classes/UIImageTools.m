//  Created by Sean Heber on 6/19/10
#import "UIImageTools.h"
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
		case kCGBlendModeClear:				return NSCompositeClear;
		case kCGBlendModeCopy:				return NSCompositeCopy;
		case kCGBlendModeSourceIn:			return NSCompositeSourceIn;
		case kCGBlendModeSourceOut:			return NSCompositeSourceOut;
		case kCGBlendModeSourceAtop:		return NSCompositeSourceAtop;
		case kCGBlendModeDestinationOver:	return NSCompositeDestinationOver;
		case kCGBlendModeDestinationIn:		return NSCompositeDestinationIn;
		case kCGBlendModeDestinationOut:	return NSCompositeDestinationOut;
		case kCGBlendModeDestinationAtop:	return NSCompositeDestinationAtop;
		case kCGBlendModeXOR:				return NSCompositeXOR;
		case kCGBlendModePlusDarker:		return NSCompositePlusDarker;
		case kCGBlendModePlusLighter:		return NSCompositePlusLighter;
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
		case kCGBlendModeNormal:
		default:
			return NSCompositeSourceOver;
	}
}
