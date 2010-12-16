//  Created by Sean Heber on 5/27/10.
#import "UIImage+UIPrivate.h"
#import "UIThreePartImage.h"
#import "UINinePartImage.h"
#import "UIGraphics.h"
#import <AppKit/NSImage.h>

@implementation UIImage

- (id)initWithNSImage:(NSImage *)theImage
{
	return [self initWithCGImage:[theImage CGImageForProposedRect:NULL context:NULL hints:nil]];
}

- (id)initWithData:(NSData *)data
{
	return [self initWithNSImage:[[[NSImage alloc] initWithData:data] autorelease]];
}

- (id)initWithContentsOfFile:(NSString *)path
{
	return [self initWithNSImage:[[[NSImage alloc] initWithContentsOfFile:[isa _pathForFile:path]] autorelease]];
}

- (id)initWithCGImage:(CGImageRef)imageRef
{
	if (!imageRef) {
		[self release];
		return nil;
	} else if ((self=[super init])) {
		_image = imageRef;
		CGImageRetain(_image);
	}
	return self;
}

- (void)dealloc
{
	if (_image) CGImageRelease(_image);
	[super dealloc];
}

+ (UIImage *)_loadImageNamed:(NSString *)name
{
	if ([name length] > 0) {
		NSString *macName = [self _macPathForFile:name];
		
		// first check for @mac version of the name
		UIImage *cachedImage = [self _cachedImageForName:macName];
		if (!cachedImage) {
			// otherwise try again with the original given name
			cachedImage = [self _cachedImageForName:name];
		}
		
		if (!cachedImage) {
			// okay, we couldn't find a cached version so now lets first try to make an original with the @mac name.
			// if that fails, try to make it with the original name.
			NSImage *image = [NSImage imageNamed:macName];
			if (!image) {
				image = [NSImage imageNamed:name];
			}
			
			if (image) {
				cachedImage = [[[self alloc] initWithNSImage:image] autorelease];
				[self _cacheImage:cachedImage forName:name];
			}
		}
		
		return cachedImage;
	} else {
		return nil;
	}
}

+ (UIImage *)imageNamed:(NSString *)name
{
	// first try it with the given name
	UIImage *image = [self _loadImageNamed:name];
	
	// if nothing is found, try again after replacing any underscores in the name with dashes.
	// I don't know why, but UIKit does something similar. it probably has a good reason and it might not be this simplistic, but
	// for now this little hack makes Ramp Champ work. :)
	if (!image) {
		image = [self _loadImageNamed:[name stringByReplacingOccurrencesOfString:@"_" withString:@"-"]];
	}
	
	return image;
}

+ (UIImage *)imageWithData:(NSData *)data
{
	return [[[self alloc] initWithData:data] autorelease];
}

+ (UIImage *)imageWithContentsOfFile:(NSString *)path
{
	return [[[self alloc] initWithContentsOfFile:path] autorelease];
}

+ (UIImage *)imageWithCGImage:(CGImageRef)imageRef
{
	return [[[self alloc] initWithCGImage:imageRef] autorelease];
}

- (UIImage *)stretchableImageWithLeftCapWidth:(NSInteger)leftCapWidth topCapHeight:(NSInteger)topCapHeight
{
	const CGSize size = self.size;
	if ((leftCapWidth == 0 && topCapHeight == 0) || (leftCapWidth >= size.width && topCapHeight >= size.height)) {
		return self;
	} else if (leftCapWidth <= 0 || leftCapWidth >= size.width) {
		return [[[UIThreePartImage alloc] initWithNSImage:[[[NSImage alloc] initWithCGImage:_image size:NSZeroSize] autorelease] capSize:MIN(topCapHeight,size.height) vertical:YES] autorelease];
	} else if (topCapHeight <= 0 || topCapHeight >= size.height) {
		return [[[UIThreePartImage alloc] initWithNSImage:[[[NSImage alloc] initWithCGImage:_image size:NSZeroSize] autorelease] capSize:MIN(leftCapWidth,size.width) vertical:NO] autorelease];
	} else {
		return [[[UINinePartImage alloc] initWithNSImage:[[[NSImage alloc] initWithCGImage:_image size:NSZeroSize] autorelease] leftCapWidth:leftCapWidth topCapHeight:topCapHeight] autorelease];
	}
}

- (void)drawAtPoint:(CGPoint)point blendMode:(CGBlendMode)blendMode alpha:(CGFloat)alpha
{
	CGSize size = self.size;
	[self drawInRect:CGRectMake(point.x,point.y,size.width,size.height) blendMode:blendMode alpha:alpha];
}

- (void)drawInRect:(CGRect)rect blendMode:(CGBlendMode)blendMode alpha:(CGFloat)alpha
{
	CGContextRef ctx = UIGraphicsGetCurrentContext();
	CGContextSaveGState(ctx);
	CGContextTranslateCTM(ctx, rect.origin.x, rect.origin.y+rect.size.height);
	CGContextScaleCTM(ctx, 1.0, -1.0);
	CGContextSetBlendMode(ctx, blendMode);
	CGContextSetAlpha(ctx, alpha);
	CGContextDrawImage(ctx, CGRectMake(0,0,rect.size.width,rect.size.height), _image);
	CGContextRestoreGState(ctx);
}

- (void)drawAtPoint:(CGPoint)point
{
	[self drawAtPoint:point blendMode:kCGBlendModeNormal alpha:1];
}

- (void)drawInRect:(CGRect)rect
{
	[self drawInRect:rect blendMode:kCGBlendModeNormal alpha:1];
}

- (CGSize)size
{
	return CGSizeMake(CGImageGetWidth(_image), CGImageGetHeight(_image));
}

- (NSInteger)leftCapWidth
{
	return 0;
}

- (NSInteger)topCapHeight
{
	return 0;
}

- (CGImageRef)CGImage
{
	return _image;
}

- (UIImageOrientation)imageOrientation
{
	return UIImageOrientationUp;
}

- (NSImage *)NSImage
{
	return [[[NSImage alloc] initWithCGImage:_image size:NSSizeFromCGSize(self.size)] autorelease];
}

- (NSBitmapImageRep *)_NSBitmapImageRep
{
	return [[[NSBitmapImageRep alloc] initWithCGImage:_image] autorelease];
}

@end

void UIImageWriteToSavedPhotosAlbum(UIImage *image, id completionTarget, SEL completionSelector, void *contextInfo)
{
}

NSData *UIImageJPEGRepresentation(UIImage *image, CGFloat compressionQuality)
{
	return [[image _NSBitmapImageRep] representationUsingType:NSJPEGFileType properties:[NSDictionary dictionaryWithObject:[NSNumber numberWithFloat:compressionQuality] forKey:NSImageCompressionFactor]];
}

NSData *UIImagePNGRepresentation(UIImage *image)
{
	return [[image _NSBitmapImageRep] representationUsingType:NSPNGFileType properties:nil];
}
