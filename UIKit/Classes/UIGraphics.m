//  Created by Sean Heber on 6/3/10.
#import "UIGraphics.h"
#import "UIImage.h"
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

void UIGraphicsBeginImageContext(CGSize size)
{
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	CGContextRef ctx = CGBitmapContextCreate(NULL, size.width, size.height, 8, 4*size.width, colorSpace, kCGImageAlphaPremultipliedLast);
	CGContextConcatCTM(ctx, CGAffineTransformMake(1, 0, 0, -1, 0, size.height));
	CGColorSpaceRelease(colorSpace);
	UIGraphicsPushContext(ctx);
	CGContextRelease(ctx);
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
