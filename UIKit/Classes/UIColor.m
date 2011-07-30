/*
 * Copyright (c) 2011, The Iconfactory. All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 *
 * 2. Redistributions in binary form must reproduce the above copyright notice,
 *    this list of conditions and the following disclaimer in the documentation
 *    and/or other materials provided with the distribution.
 *
 * 3. Neither the name of The Iconfactory nor the names of its contributors may
 *    be used to endorse or promote products derived from this software without
 *    specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE ICONFACTORY BE LIABLE FOR ANY DIRECT,
 * INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
 * BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
 * LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
 * OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
 * ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import "UIColor.h"
#import "UIImage.h"
#import "UIGraphics.h"
#import <AppKit/NSColor.h>
#import <AppKit/NSColorSpace.h>

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

static CGPatternRef CreateImagePattern(CGImageRef image)
{
    NSCParameterAssert(image);
    CGImageRetain(image);
    int width = CGImageGetWidth(image);
    int height = CGImageGetHeight(image);
    static const CGPatternCallbacks callbacks = {0, &drawPatternImage, &releasePatternImage};
    return CGPatternCreate (image,
                            CGRectMake (0, 0, width, height),
                            CGAffineTransformMake (1, 0, 0, -1, 0, height),
                            width,
                            height,
                            kCGPatternTilingConstantSpacing,
                            true,
                            &callbacks);
}

static CGColorRef CreatePatternColor(CGImageRef image)
{
    CGPatternRef pattern = CreateImagePattern(image);
    CGColorSpaceRef space = CGColorSpaceCreatePattern(NULL);
    CGFloat components[1] = {1.0};
    CGColorRef color = CGColorCreateWithPattern(space, pattern, components);
    CGColorSpaceRelease(space);
    CGPatternRelease(pattern);
    return color;
}

static UIColor *BlackColor = nil;
static UIColor *DarkGrayColor = nil;
static UIColor *LightGrayColor = nil;
static UIColor *WhiteColor = nil;
static UIColor *GrayColor = nil;
static UIColor *RedColor = nil;
static UIColor *GreenColor = nil;
static UIColor *BlueColor = nil;
static UIColor *CyanColor = nil;
static UIColor *YellowColor = nil;
static UIColor *MagentaColor = nil;
static UIColor *OrangeColor = nil;
static UIColor *PurpleColor = nil;
static UIColor *BrownColor = nil;
static UIColor *ClearColor = nil;

@implementation UIColor

- (id)initWithNSColor:(NSColor *)aColor
{
    if ((self=[super init])) {
        NSColor *c = [aColor colorUsingColorSpace:[NSColorSpace deviceRGBColorSpace]];
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

+ (id)colorWithNSColor:(NSColor *)c
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

+ (UIColor *)blackColor			{ return BlackColor ?: (BlackColor = [[self alloc] initWithNSColor:[NSColor blackColor]]); }
+ (UIColor *)darkGrayColor		{ return DarkGrayColor ?: (DarkGrayColor = [[self alloc] initWithNSColor:[NSColor darkGrayColor]]); }
+ (UIColor *)lightGrayColor		{ return LightGrayColor ?: (LightGrayColor = [[self alloc] initWithNSColor:[NSColor lightGrayColor]]); }
+ (UIColor *)whiteColor			{ return WhiteColor ?: (WhiteColor = [[self alloc] initWithNSColor:[NSColor whiteColor]]); }
+ (UIColor *)grayColor			{ return GrayColor ?: (GrayColor = [[self alloc] initWithNSColor:[NSColor grayColor]]); }
+ (UIColor *)redColor			{ return RedColor ?: (RedColor = [[self alloc] initWithNSColor:[NSColor redColor]]); }
+ (UIColor *)greenColor			{ return GreenColor ?: (GreenColor = [[self alloc] initWithNSColor:[NSColor greenColor]]); }
+ (UIColor *)blueColor			{ return BlueColor ?: (BlueColor = [[self alloc] initWithNSColor:[NSColor blueColor]]); }
+ (UIColor *)cyanColor			{ return CyanColor ?: (CyanColor = [[self alloc] initWithNSColor:[NSColor cyanColor]]); }
+ (UIColor *)yellowColor		{ return YellowColor ?: (YellowColor = [[self alloc] initWithNSColor:[NSColor yellowColor]]); }
+ (UIColor *)magentaColor		{ return MagentaColor ?: (MagentaColor = [[self alloc] initWithNSColor:[NSColor magentaColor]]); }
+ (UIColor *)orangeColor		{ return OrangeColor ?: (OrangeColor = [[self alloc] initWithNSColor:[NSColor orangeColor]]); }
+ (UIColor *)purpleColor		{ return PurpleColor ?: (PurpleColor = [[self alloc] initWithNSColor:[NSColor purpleColor]]); }
+ (UIColor *)brownColor			{ return BrownColor ?: (BrownColor = [[self alloc] initWithNSColor:[NSColor brownColor]]); }
+ (UIColor *)clearColor			{ return ClearColor ?: (ClearColor = [[self alloc] initWithNSColor:[NSColor clearColor]]); }

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
    if (!patternImage) {
        [self release];
        self = nil;
    } else if ((self=[super init])) {
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

- (NSString *)description
{
    // The color space string this gets isn't exactly the same as Apple's implementation.
    // For instance, Apple's implementation returns UIDeviceRGBColorSpace for [UIColor redColor]
    // This implementation returns kCGColorSpaceDeviceRGB instead.
    // Apple doesn't actually define UIDeviceRGBColorSpace or any of the other responses anywhere public,
    // so there isn't any easy way to emulate it.
    CGColorSpaceRef colorSpaceRef = CGColorGetColorSpace(self.CGColor);
    NSString *colorSpace = [NSString stringWithFormat:@"%@", [(NSString *)CGColorSpaceCopyName(colorSpaceRef) autorelease]];

    const size_t numberOfComponents = CGColorGetNumberOfComponents(self.CGColor);
    const CGFloat *components = CGColorGetComponents(self.CGColor);
    NSMutableString *componentsString = [NSMutableString stringWithString:@"{"];
    
    for (NSInteger index = 0; index < numberOfComponents; index++) {
        if (index) [componentsString appendString:@", "];
        [componentsString appendFormat:@"%.0f", components[index]];
    }
    [componentsString appendString:@"}"];

    return [NSString stringWithFormat:@"<%@: %p; colorSpace = %@; components = %@>", [self className], self, colorSpace, componentsString];
}

@end
