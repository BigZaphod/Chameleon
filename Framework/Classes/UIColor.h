//  Created by Sean Heber on 5/27/10.
#import <Foundation/Foundation.h>

@class UIImage, NSColor;

@interface UIColor : NSObject {
@private
	CGColorRef _color;
}

+ (UIColor *)colorWithNSColor:(NSColor *)c;
- (id)initWithNSColor:(NSColor *)c;

+ (UIColor *)colorWithWhite:(CGFloat)white alpha:(CGFloat)alpha;
+ (UIColor *)colorWithHue:(CGFloat)hue saturation:(CGFloat)saturation brightness:(CGFloat)brightness alpha:(CGFloat)alpha;
+ (UIColor *)colorWithRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue alpha:(CGFloat)alpha;
+ (UIColor *)colorWithCGColor:(CGColorRef)ref;
+ (UIColor *)colorWithPatternImage:(UIImage *)patternImage;

+ (UIColor *)blackColor;
+ (UIColor *)darkGrayColor;
+ (UIColor *)lightGrayColor;
+ (UIColor *)whiteColor;
+ (UIColor *)grayColor;
+ (UIColor *)redColor;
+ (UIColor *)greenColor;
+ (UIColor *)blueColor;
+ (UIColor *)cyanColor;
+ (UIColor *)yellowColor;
+ (UIColor *)magentaColor;
+ (UIColor *)orangeColor;
+ (UIColor *)purpleColor;
+ (UIColor *)brownColor;
+ (UIColor *)clearColor;

- (id)initWithWhite:(CGFloat)white alpha:(CGFloat)alpha;
- (id)initWithHue:(CGFloat)hue saturation:(CGFloat)saturation brightness:(CGFloat)brightness alpha:(CGFloat)alpha;
- (id)initWithRed:(CGFloat)red green:(CGFloat)green blue:(CGFloat)blue alpha:(CGFloat)alpha;
- (id)initWithCGColor:(CGColorRef)ref;
- (id)initWithPatternImage:(UIImage *)patternImage;

- (UIColor *)colorWithAlphaComponent:(CGFloat)alpha;

- (void)set;
- (void)setFill;
- (void)setStroke;

@property (nonatomic, readonly) CGColorRef CGColor;

@end
