#import "UITableViewCellBackgroundView.h"


@implementation UITableViewCellBackgroundView

- (void)drawRect:(CGRect)dirtyRect
{
    
	float radius = 10.0;
	
	int lineWidth = 1;
	
	CGRect rect = [self bounds];
	
	rect.size.width -= lineWidth;
	rect.size.height -= lineWidth;
	rect.origin.x += lineWidth / 2.0;
	rect.origin.y += lineWidth / 2.0;
	
	CGFloat minX = CGRectGetMinX(rect), midX = CGRectGetMidX(rect), maxX = CGRectGetMaxX(rect);
	CGFloat minY = CGRectGetMinY(rect), maxY = CGRectGetMaxY(rect);
	
	maxY += 1;
	
	CGContextRef c = UIGraphicsGetCurrentContext();
	
	CGContextSetLineWidth(c, lineWidth);
    //	CGContextSetAllowsAntialiasing(c, YES);
    //	CGContextSetShouldAntialias(c, YES);
	
	
	UITableViewCell* cell = (UITableViewCell*)[self superview];
    NSAssert([cell isKindOfClass:[UITableViewCell class]], nil);
	if ([cell sectionLocation] == UITableViewCellSectionLocationTop) {
		//minY += 1;
        
		CGContextClearRect(c, [self bounds]);
		CGContextBeginPath(c);
		CGContextMoveToPoint(c, minX,maxY);
		CGContextAddArcToPoint(c,minX, minY, midX, minY, radius);
		CGContextAddArcToPoint(c,maxX, minY, maxX, maxY, radius);
		CGContextAddLineToPoint(c, maxX, maxY);
		CGContextSaveGState(c);
		CGColorRef fillColor = [self.backgroundColor CGColor];
		CGContextSetFillColorWithColor(c, fillColor);
		CGContextSetRGBStrokeColor(c, .67f, .67f, .67f, 1.0);
		
		CGContextDrawPath(c, kCGPathFillStroke);
		CGContextRestoreGState(c);
	}
	else if ([cell sectionLocation] == UITableViewCellSectionLocationBottom) {
		CGContextSaveGState(c);
		CGContextClearRect(c, [self bounds]);
		CGContextSetRGBStrokeColor(c, .67f, .67f, .67f, 1.0);
		CGContextBeginPath(c);
		CGContextMoveToPoint(c, minX,minY-1.0f);
		CGContextAddArcToPoint(c,minX, maxY-1.0f, midX, maxY, radius);
		CGContextAddArcToPoint(c,maxX, maxY-1.0f, maxX, minY-1.0f, radius);
		CGContextAddLineToPoint(c, maxX, minY-1.0f);
		CGColorRef fillColor = [self.backgroundColor CGColor];
		CGContextSetFillColorWithColor(c, fillColor);
		CGContextDrawPath(c, kCGPathFillStroke);
		CGContextRestoreGState(c);
	}
	else {
		
		
		CGContextSaveGState(c);
		CGContextSetFillColorWithColor(c, [self.backgroundColor CGColor]);
		CGContextFillRect(c, rect);
		CGContextRestoreGState(c);
		
		
		CGContextBeginPath(c);
		CGContextMoveToPoint(c, minX,minY-1.0f);
		CGContextAddLineToPoint(c, minX, maxY);
		CGContextSaveGState(c);
		CGContextSetRGBStrokeColor(c, .67f, .67f, .67f, 1.0);
		CGContextStrokePath(c);
		CGContextRestoreGState(c);
		
		
		CGContextBeginPath(c);
		CGContextMoveToPoint(c, maxX,minY-1.0f);
		CGContextAddLineToPoint(c, maxX, maxY);
		CGContextSaveGState(c);
		CGContextSetRGBStrokeColor(c, .67f, .67f, .67f, 1.0);
		CGContextStrokePath(c);
		CGContextRestoreGState(c);
		
	}
	
	
	
}

@end

