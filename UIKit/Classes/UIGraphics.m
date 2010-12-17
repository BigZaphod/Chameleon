//  Created by Sean Heber on 6/3/10.
#import "UIGraphics.h"
#import "UIImage.h"
#import "UIScreen.h"
#import <AppKit/AppKit.h>

typedef struct UISavedGraphicsContext_ {
	NSGraphicsContext *context;
	struct UISavedGraphicsContext_ *previous;
} UISavedGraphicsContext;

static UISavedGraphicsContext *contextStack = NULL;

void UIGraphicsPushContext(CGContextRef ctx)
{
	UISavedGraphicsContext *savedContext = malloc(sizeof(UISavedGraphicsContext));
	savedContext->context = [[NSGraphicsContext currentContext] retain];
	savedContext->previous = contextStack;
	contextStack = savedContext;
	CGContextRetain(ctx);
	[NSGraphicsContext setCurrentContext:[NSGraphicsContext graphicsContextWithGraphicsPort:(void *)ctx flipped:YES]];
}

void UIGraphicsPopContext()
{
	UISavedGraphicsContext *popContext = contextStack;
	if (popContext) {
		CGContextRelease([[NSGraphicsContext currentContext] graphicsPort]);
		contextStack = popContext->previous;
		[NSGraphicsContext setCurrentContext:popContext->context];
		[popContext->context release];
		free(popContext);
	}
}

CGContextRef UIGraphicsGetCurrentContext()
{
	return [[NSGraphicsContext currentContext] graphicsPort];
}

void UIGraphicsBeginImageContextWithOptions(CGSize size, BOOL opaque, CGFloat scale)
{
	if (scale == 0.f) {
		scale = [UIScreen mainScreen].scale;
	}
	
	const size_t width = size.width * scale;
	const size_t height = size.height * scale;

	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	CGContextRef ctx = CGBitmapContextCreate(NULL, width, height, 8, 4*width, colorSpace, (opaque? kCGImageAlphaNoneSkipFirst : kCGImageAlphaPremultipliedFirst));
	CGContextConcatCTM(ctx, CGAffineTransformMake(1, 0, 0, -1, 0, height));
	CGContextScaleCTM(ctx, 1.f/scale, 1.f/scale);
	CGColorSpaceRelease(colorSpace);
	UIGraphicsPushContext(ctx);
	CGContextRelease(ctx);
}

void UIGraphicsBeginImageContext(CGSize size)
{
	UIGraphicsBeginImageContextWithOptions(size, NO, 1.f);
}

UIImage *UIGraphicsGetImageFromCurrentImageContext()
{
	CGImageRef theCGImage = CGBitmapContextCreateImage(UIGraphicsGetCurrentContext());
	UIImage *image = [UIImage imageWithCGImage:theCGImage];
	CGImageRelease(theCGImage);
	return image;
}

void UIGraphicsEndImageContext()
{
	UIGraphicsPopContext();
}

void UIRectFill(CGRect rect)
{
	UIRectFillUsingBlendMode(rect, kCGBlendModeCopy);
}

void UIRectFillUsingBlendMode(CGRect rect, CGBlendMode blendMode)
{
	CGContextRef c = UIGraphicsGetCurrentContext();
	CGContextSaveGState(c);
	CGContextSetBlendMode(c, blendMode);
	CGContextFillRect(c, rect);
	CGContextRestoreGState(c);
}

void UIRectFrame(CGRect rect)
{
	CGContextStrokeRect(UIGraphicsGetCurrentContext(), rect);
}

void UIRectFrameUsingBlendMode(CGRect rect, CGBlendMode blendMode)
{
	CGContextRef c = UIGraphicsGetCurrentContext();
	CGContextSaveGState(c);
	CGContextSetBlendMode(c, blendMode);
	UIRectFrame(rect);
	CGContextRestoreGState(c);
}
