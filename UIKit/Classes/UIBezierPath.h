//  Created by Sean Heber on 6/24/10.
#import <Foundation/Foundation.h>

enum {
	UIRectCornerTopLeft     = 1 << 0,
	UIRectCornerTopRight    = 1 << 1,
	UIRectCornerBottomLeft  = 1 << 2,
	UIRectCornerBottomRight = 1 << 3,
	UIRectCornerAllCorners  = ~0
};
typedef NSUInteger UIRectCorner;

@interface UIBezierPath : NSObject {
@private
	CGPathRef _path;
	CGFloat _lineWidth;
	CGLineCap _lineCapStyle;
	CGLineJoin _lineJoinStyle;
	CGFloat _miterLimit;
	CGFloat _flatness;
	BOOL _usesEvenOddFillRule;
	CGFloat *_lineDashPattern;
	NSInteger _lineDashCount;
	CGFloat _lineDashPhase;
}

+ (UIBezierPath *)bezierPath;
+ (UIBezierPath *)bezierPathWithRect:(CGRect)rect;
+ (UIBezierPath *)bezierPathWithOvalInRect:(CGRect)rect;
+ (UIBezierPath *)bezierPathWithRoundedRect:(CGRect)rect cornerRadius:(CGFloat)cornerRadius;
+ (UIBezierPath *)bezierPathWithRoundedRect:(CGRect)rect byRoundingCorners:(UIRectCorner)corners cornerRadii:(CGSize)cornerRadii;
+ (UIBezierPath *)bezierPathWithArcCenter:(CGPoint)center radius:(CGFloat)radius startAngle:(CGFloat)startAngle endAngle:(CGFloat)endAngle clockwise:(BOOL)clockwise;
+ (UIBezierPath *)bezierPathWithCGPath:(CGPathRef)CGPath;

- (void)moveToPoint:(CGPoint)point;
- (void)addLineToPoint:(CGPoint)point;
- (void)addArcWithCenter:(CGPoint)center radius:(CGFloat)radius startAngle:(CGFloat)startAngle endAngle:(CGFloat)endAngle clockwise:(BOOL)clockwise;
- (void)addCurveToPoint:(CGPoint)endPoint controlPoint1:(CGPoint)controlPoint1 controlPoint2:(CGPoint)controlPoint2;
- (void)addQuadCurveToPoint:(CGPoint)endPoint controlPoint:(CGPoint)controlPoint;
- (void)closePath;
- (void)removeAllPoints;
- (void)appendPath:(UIBezierPath *)bezierPath;

@property (nonatomic) CGPathRef CGPath;
@property (nonatomic, readonly) CGPoint currentPoint;

@property (nonatomic) CGFloat lineWidth;
@property (nonatomic) CGLineCap lineCapStyle;
@property (nonatomic) CGLineJoin lineJoinStyle;
@property (nonatomic) CGFloat miterLimit;
@property (nonatomic) CGFloat flatness;
@property (nonatomic) BOOL usesEvenOddFillRule;

- (void)setLineDash:(const CGFloat *)pattern count:(NSInteger)count phase:(CGFloat)phase;
- (void)getLineDash:(CGFloat *)pattern count:(NSInteger *)count phase:(CGFloat *)phase;

- (void)fill;
- (void)fillWithBlendMode:(CGBlendMode)blendMode alpha:(CGFloat)alpha;

- (void)stroke;
- (void)strokeWithBlendMode:(CGBlendMode)blendMode alpha:(CGFloat)alpha;

- (void)addClip;

- (BOOL)containsPoint:(CGPoint)point;

@property (readonly, getter=isEmpty) BOOL empty;
@property (nonatomic, readonly) CGRect bounds;

- (void)applyTransform:(CGAffineTransform)transform;

@end
