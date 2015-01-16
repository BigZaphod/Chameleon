//CustomCellBackgroundView.m
#import "CustomCellBackgroundView.h"
#import <QuartzCore/QuartzCore.h>

#define ROUND_SIZE 3
#define LINE_WIDTH 1.5f

static void addRoundedRectToPath(CGContextRef context, CGRect rect,
                                 float ovalWidth, float ovalHeight);

@implementation CustomCellBackgroundView
@synthesize borderColor, fillColor, position, useBlueSelectionGradient;
@synthesize gradientStartColor, gradientEndColor;

- (BOOL)isOpaque {
    return NO;
}

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        // Initialization code
        selectGradient = NULL;
        gradient = NULL;
    }
    return self;
}

- (void)createGradient {
    if (gradient != NULL) {
        CGGradientRelease(gradient);
        gradient = NULL;
    }
    
    if (self.gradientStartColor && self.gradientEndColor) {
        const float *topColor = CGColorGetComponents([self.gradientStartColor CGColor]);
        const float *bottomColor = CGColorGetComponents([self.gradientEndColor CGColor]);
        
        CGColorSpaceRef rgb = CGColorSpaceCreateDeviceRGB();
        CGFloat colors[] = {
            topColor[0],    topColor[1],    topColor[2],    topColor[3],
            bottomColor[0], bottomColor[1], bottomColor[2], bottomColor[3]
        };
        size_t numColors = sizeof(colors) / (sizeof(colors[0]) * 4);
        gradient = CGGradientCreateWithColorComponents(rgb, colors, NULL, numColors);
        CGColorSpaceRelease(rgb);
    }
}

- (void)setUseBlueSelectionGradient:(BOOL)newValue {
    useBlueSelectionGradient = newValue;
    if (useBlueSelectionGradient && selectGradient == NULL) {
        CGColorSpaceRef rgb = CGColorSpaceCreateDeviceRGB();
        CGFloat colors[] = {
            5.0 / 255.0, 140.0 / 255.0, 245.0 / 255.0, 1.00,
            1.0 / 255.0,  93.0 / 255.0, 230.0 / 255.0, 1.00,
        };
        size_t numColors = sizeof(colors) / (sizeof(colors[0]) * 4);
        selectGradient = CGGradientCreateWithColorComponents(rgb, colors, NULL, numColors);
        CGColorSpaceRelease(rgb);
        [self setNeedsDisplay];
    }
    else if (!useBlueSelectionGradient && selectGradient != NULL) {
        CGGradientRelease(selectGradient);
        selectGradient = NULL;
        [self setNeedsDisplay];
    }
}

- (void)setGradientStartColor:(UIColor *)inColor {
    if (inColor != gradientStartColor) {
        gradientStartColor = inColor;
        [self createGradient];
    }
}

- (void)setGradientEndColor:(UIColor *)inColor {
    if (inColor != gradientEndColor) {
        gradientEndColor = inColor;
        [self createGradient];
    }
}

- (void)setPosition:(CustomCellBackgroundViewPosition)inPosition {
    if (position != inPosition) {
        position = inPosition;
        [self setNeedsDisplay];
    }
}

- (void)useBlackGradient {
    self.gradientStartColor = [UIColor colorWithRed:0.154 green:0.154 blue:0.154 alpha:1.0];
    self.gradientEndColor = [UIColor colorWithRed:0.307 green:0.307 blue:0.307 alpha:1.0];
}

- (void)useWhiteGradient {
    self.gradientStartColor = [UIColor colorWithRed:0.864 green:0.864 blue:0.864 alpha:1.0];
    self.gradientEndColor = [UIColor colorWithRed:0.956 green:0.956 blue:0.956 alpha:1.0];
}

- (void)drawRect:(CGRect)rect {
    // Drawing code
    CGContextRef c = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(c, [fillColor CGColor]);
    CGContextSetStrokeColorWithColor(c, [borderColor CGColor]);
    CGContextSetLineWidth(c, 2);
    CGSize corners = CGSizeMake(ROUND_SIZE, ROUND_SIZE);
    
    // set these for bottom / single cells
    self.layer.shadowColor =  [UIColor colorWithWhite:0.694 alpha:1.000].CGColor;
    self.layer.shadowOpacity = 0.7f;
    self.layer.shadowOffset = CGSizeMake(0.0f, 2);
    self.layer.shadowRadius = 1.0f;
    self.layer.masksToBounds = NO;
    //force this to null to prevent cells re-using
    self.layer.shadowPath = [UIBezierPath bezierPathWithRect:CGRectZero].CGPath;
    
    CGFloat minx = CGRectGetMinX(rect); // , midx = CGRectGetMidX(rect), maxx = CGRectGetMaxX(rect) ;
    CGFloat miny = CGRectGetMinY(rect); // , midy = CGRectGetMidY(rect) ,
    CGFloat maxy = CGRectGetMaxY(rect);
    
    if (position == CustomCellBackgroundViewPositionTop) {
        UIBezierPath *roundedPath =  [UIBezierPath bezierPathWithRoundedRect:rect byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight cornerRadii:corners];
        roundedPath.lineWidth = LINE_WIDTH;
        roundedPath.lineCapStyle = kCGLineCapRound;
        roundedPath.lineJoinStyle = kCGLineJoinRound;
        [roundedPath fill];
        [roundedPath stroke];
    }
    else if (position == CustomCellBackgroundViewPositionBottom) {
        UIBezierPath *roundedPath =  [UIBezierPath bezierPathWithRoundedRect:rect byRoundingCorners:UIRectCornerBottomLeft | UIRectCornerBottomRight cornerRadii:corners];
        roundedPath.lineWidth = LINE_WIDTH;
        roundedPath.lineCapStyle = kCGLineCapRound;
        roundedPath.lineJoinStyle = kCGLineJoinRound;
        [roundedPath fill];
        [roundedPath stroke];
        
        UIBezierPath *topLine =  [UIBezierPath bezierPathWithRect:CGRectMake(rect.origin.x + 1.0, rect.origin.y, rect.size.width - 2, LINE_WIDTH)];
        [topLine fill];
    }
    else if (position == CustomCellBackgroundViewPositionMiddle) {
        UIBezierPath *center =  [UIBezierPath bezierPathWithRect:CGRectMake(rect.origin.x, rect.origin.y, rect.size.width, rect.size.height)];
        [center fill]; // white body
        UIBezierPath *leftLine =  [UIBezierPath bezierPathWithRect:CGRectMake(rect.origin.x, rect.origin.y, 0, rect.size.height)];
        leftLine.lineWidth = LINE_WIDTH;
        leftLine.lineCapStyle = kCGLineCapRound;
        leftLine.lineJoinStyle = kCGLineJoinRound;
        [leftLine stroke];
        UIBezierPath *rightLine =  [UIBezierPath bezierPathWithRect:CGRectMake(rect.origin.x + rect.size.width, rect.origin.y, 0, rect.size.height)];
        rightLine.lineWidth = LINE_WIDTH;
        rightLine.lineCapStyle = kCGLineCapRound;
        rightLine.lineJoinStyle = kCGLineJoinRound;
        [rightLine stroke];
        UIBezierPath *baseLine =  [UIBezierPath bezierPathWithRect:CGRectMake(rect.origin.x, rect.size.height, rect.size.width, LINE_WIDTH)];
        [baseLine stroke];
        //force this to null to prevent cells
        self.layer.shadowPath = [UIBezierPath bezierPathWithRect:CGRectZero].CGPath;
    }
    else if (position == CustomCellBackgroundViewPositionSingle) {
        UIBezierPath *dropShadowPath =  [UIBezierPath bezierPathWithRoundedRect:rect byRoundingCorners:UIRectCornerAllCorners cornerRadii:corners];
        self.layer.shadowPath = dropShadowPath.CGPath;
        
        UIBezierPath *roundedPath =  [UIBezierPath bezierPathWithRoundedRect:rect byRoundingCorners:UIRectCornerAllCorners cornerRadii:corners];
        [roundedPath stroke];
        [roundedPath fill];
    }
    else if (position == CustomCellBackgroundViewPositionAvataorSingle) {
        UIBezierPath *dropShadowPath =  [UIBezierPath bezierPathWithRoundedRect:CGRectMake(rect.origin.x + 90, rect.origin.y, rect.size.width - 90, rect.size.height - 1.0f)  byRoundingCorners:UIRectCornerAllCorners cornerRadii:corners];
        self.layer.shadowPath = dropShadowPath.CGPath;
        
        UIBezierPath *roundedPath =  [UIBezierPath bezierPathWithRoundedRect:CGRectMake(rect.origin.x + 90, rect.origin.y, rect.size.width - 90, rect.size.height)  byRoundingCorners:UIRectCornerAllCorners cornerRadii:corners];
        [roundedPath stroke];
        [roundedPath fill];
    }
    else {
        return;
    }
    
    // Close the path
    // CGContextClosePath(c);
    
    if (selectGradient != NULL || gradient != NULL) {
        CGContextSaveGState(c);
        CGContextClip(c);
        
        UIBezierPath *roundedPath;
        if (position == CustomCellBackgroundViewPositionTop) {
            roundedPath = [UIBezierPath bezierPathWithRoundedRect:rect byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight cornerRadii:corners];
        }
        else if (position == CustomCellBackgroundViewPositionBottom) {
            roundedPath = [UIBezierPath bezierPathWithRoundedRect:rect byRoundingCorners:UIRectCornerBottomLeft | UIRectCornerBottomRight cornerRadii:corners];
        }
        else if (position == CustomCellBackgroundViewPositionMiddle) {
            roundedPath = [UIBezierPath bezierPathWithRect:rect];
        }
        else { //if (position == CustomCellBackgroundViewPositionSingle)
            roundedPath = [UIBezierPath bezierPathWithRoundedRect:rect byRoundingCorners:UIRectCornerAllCorners cornerRadii:corners];
        }
        
        CGContextSaveGState(c);
        [roundedPath fill];
        [roundedPath addClip];
        CGContextDrawLinearGradient(c,
                                    selectGradient != NULL ? selectGradient : gradient,
                                    CGPointMake(minx, miny),
                                    CGPointMake(minx, maxy),
                                    kCGGradientDrawsBeforeStartLocation | kCGGradientDrawsAfterEndLocation);
    }
    else {
        CGContextDrawPath(c, kCGPathFillStroke);
    }
}

- (void)dealloc {
    if (selectGradient != NULL) {
        CGGradientRelease(selectGradient);
        selectGradient = NULL;
    }
    if (gradient != NULL) {
        CGGradientRelease(gradient);
        gradient = NULL;
    }
}

@end

static void addRoundedRectToPath(CGContextRef context, CGRect rect,
                                 float ovalWidth, float ovalHeight) {
    float fw, fh;
    
    if (ovalWidth == 0 || ovalHeight == 0) { // 1
        CGContextAddRect(context, rect);
        return;
    }
    
    CGContextSaveGState(context); // 2
    
    CGContextSetShouldAntialias(context, YES);
    CGContextTranslateCTM(context, CGRectGetMinX(rect), // 3
                          CGRectGetMinY(rect));
    CGContextScaleCTM(context, ovalWidth, ovalHeight); // 4
    fw = CGRectGetWidth(rect) / ovalWidth; // 5
    fh = CGRectGetHeight(rect) / ovalHeight; // 6
    
    CGContextMoveToPoint(context, fw, fh / 2); // 7
    CGContextAddArcToPoint(context, fw, fh, fw / 2, fh, 1); // 8
    CGContextAddArcToPoint(context, 0, fh, 0, fh / 2, 1); // 9
    CGContextAddArcToPoint(context, 0, 0, fw / 2, 0, 1); // 10
    CGContextAddArcToPoint(context, fw, 0, fw, fh / 2, 1); // 11
    CGContextClosePath(context); // 12
    
    CGContextRestoreGState(context); // 13
}
