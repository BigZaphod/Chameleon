//  Created by Sean Heber on 5/27/10.
#import "UIColor.h"
#import "UIImage.h"
#import "UIGraphics.h"
#import <AppKit/AppKit.h>

// callback for CreateImagePattern.
static void drawPatternImage(void *info, CGContextRef ctx)
{
    CGImageRef image = (CGImageRef)info;
    CGContextDrawImage(ctx, CGRectMake(0,0, CGImageGetWidth(image),CGImageGetHeight(image)), image);
}

// callback for CreateImagePattern.
static void releasePatternImage(void *info)
{
    CGImageRelease((CGImageRef)info);
}

CGPatternRef CreateImagePattern(CGImageRef image)
{
    NSCParameterAssert(image);
	CGImageRetain(image);
    int width = CGImageGetWidth(image);
    int height = CGImageGetHeight(image);
    static const CGPatternCallbacks callbacks = {0, &drawPatternImage, &releasePatternImage};
    return CGPatternCreate (image,
                            CGRectMake (0, 0, width, height),
                            CGAffineTransformMake (1, 0, 0, 1, 0, 0),
                            width,
                            height,
                            kCGPatternTilingConstantSpacing,
                            true,
                            &callbacks);
}

CGColorRef CreatePatternColor(CGImageRef image)
{
    CGPatternRef pattern = CreateImagePattern(image);
    CGColorSpaceRef space = CGColorSpaceCreatePattern(NULL);
    CGFloat components[1] = {1.0};
    CGColorRef color = CGColorCreateWithPattern(space, pattern, components);
    CGColorSpaceRelease(space);
    CGPatternRelease(pattern);
    return color;
}

@implementation UIColor

- (id)initWithNSColor:(NSColor *)c
{
	if ((self=[super init])) {
		CGFloat components[[c numberOfComponents]];
		[c getComponents:components];
		_color = CGColorCreate([[c colorSpace] CGColorSpace], components);
	}
	return self;
}

- (void)dealloc
{
	CGColorRelease(_color);
	[super dealloc];
}

+ (UIColor *)_colorWithNSColor:(NSColor *)c
{
	return [[[self alloc] initWithNSColor:c] autorelease];
}

+ (UIColor *)colorWithWhite:(CGFloat)white alpha:(CGFloat)alpha
{
	return [[[self alloc] initWithWhite:white alpha:alpha] autorelease];
}

+ (UIColor *)colorWithHue:(CGFloat)hue saturation:(CGFloat)saturation brightness:(CGFloat)brightness alpha:(CGFloat)alpha
{
	return [[[self alloc] initWithHue:hue saturation:saturation brightness:brightness alpha:alpha] autorelease];
}

+ (UIColor *)colorWithRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue alpha:(CGFloat)alpha
{
	return [[[self alloc] initWithRed:red green:green blue:blue alpha:alpha] autorelease];
}

+ (UIColor *)colorWithCGColor:(CGColorRef)ref
{
	return [[[self alloc] initWithCGColor:ref] autorelease];
}

+ (UIColor *)colorWithPatternImage:(UIImage *)patternImage
{
	return [[[self alloc] initWithPatternImage:patternImage] autorelease];
}

+ (UIColor *)blackColor			{ return [self _colorWithNSColor:[NSColor blackColor]]; }
+ (UIColor *)darkGrayColor		{ return [self _colorWithNSColor:[NSColor darkGrayColor]]; }
+ (UIColor *)lightGrayColor		{ return [self _colorWithNSColor:[NSColor lightGrayColor]]; }
+ (UIColor *)whiteColor			{ return [self _colorWithNSColor:[NSColor whiteColor]]; }
+ (UIColor *)grayColor			{ return [self _colorWithNSColor:[NSColor grayColor]]; }
+ (UIColor *)redColor			{ return [self _colorWithNSColor:[NSColor redColor]]; }
+ (UIColor *)greenColor			{ return [self _colorWithNSColor:[NSColor greenColor]]; }
+ (UIColor *)blueColor			{ return [self _colorWithNSColor:[NSColor blueColor]]; }
+ (UIColor *)cyanColor			{ return [self _colorWithNSColor:[NSColor cyanColor]]; }
+ (UIColor *)yellowColor		{ return [self _colorWithNSColor:[NSColor yellowColor]]; }
+ (UIColor *)magentaColor		{ return [self _colorWithNSColor:[NSColor magentaColor]]; }
+ (UIColor *)orangeColor		{ return [self _colorWithNSColor:[NSColor orangeColor]]; }
+ (UIColor *)purpleColor		{ return [self _colorWithNSColor:[NSColor purpleColor]]; }
+ (UIColor *)brownColor			{ return [self _colorWithNSColor:[NSColor brownColor]]; }
+ (UIColor *)clearColor			{ return [self _colorWithNSColor:[NSColor clearColor]]; }

- (id)initWithWhite:(CGFloat)white alpha:(CGFloat)alpha
{
	return [self initWithNSColor:[NSColor colorWithDeviceWhite:white alpha:alpha]];
}

- (id)initWithHue:(CGFloat)hue saturation:(CGFloat)saturation brightness:(CGFloat)brightness alpha:(CGFloat)alpha
{
	return [self initWithNSColor:[NSColor colorWithDeviceHue:hue saturation:saturation brightness:brightness alpha:alpha]];
}

- (id)initWithRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue alpha:(CGFloat)alpha
{
	return [self initWithNSColor:[NSColor colorWithDeviceRed:red green:green blue:blue alpha:alpha]];
}

- (id)initWithCGColor:(CGColorRef)ref
{
	return [self initWithNSColor:[NSColor colorWithCIColor:[CIColor colorWithCGColor:ref]]];
}

- (id)initWithPatternImage:(UIImage *)patternImage
{
	if ((self=[super init])) {
		_color = CreatePatternColor(patternImage.CGImage);
	}

	return self;
}

- (void)set
{
	[self setFill];
	[self setStroke];
}

- (void)setFill
{
	CGContextSetFillColorWithColor(UIGraphicsGetCurrentContext(), _color);
}

- (void)setStroke
{
	CGContextSetStrokeColorWithColor(UIGraphicsGetCurrentContext(), _color);
}

- (CGColorRef)CGColor
{
	return _color;
}

- (UIColor *)colorWithAlphaComponent:(CGFloat)alpha
{
	CGColorRef newColor = CGColorCreateCopyWithAlpha(_color, alpha);
	UIColor *resultingUIColor = [UIColor colorWithCGColor:newColor];
	CGColorRelease(newColor);
	return resultingUIColor;
}

- (NSColor *)NSColor
{
	NSColorSpace *colorSpace = [[NSColorSpace alloc] initWithCGColorSpace:CGColorGetColorSpace(_color)];
	const NSInteger numberOfComponents = CGColorGetNumberOfComponents(_color);
	const CGFloat *components = CGColorGetComponents(_color);
	NSColor *theColor = [NSColor colorWithColorSpace:colorSpace components:components count:numberOfComponents];
	[colorSpace release];
	return theColor;
}

@end
