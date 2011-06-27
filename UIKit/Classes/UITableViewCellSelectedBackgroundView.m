#import "UITableViewCellSelectedBackgroundView.h"
#import "UIImage+UIPrivate.h"


@implementation UITableViewCellSelectedBackgroundView

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
	//CGContextSetAllowsAntialiasing(c, YES);
	//CGContextSetShouldAntialias(c, YES);
	UITableViewCell* cell = (UITableViewCell*)[self superview];
    NSAssert([cell isKindOfClass:[UITableViewCell class]], nil);
	if ([cell sectionLocation]==UITableViewCellSectionLocationTop) {
		
		CGContextClearRect(c, rect);
		
		CGRect imageRect = self.bounds;
        
		CGMutablePathRef path = CGPathCreateMutable();
		CGPathMoveToPoint(path, NULL, minX, maxY);
		CGPathAddArcToPoint(path, NULL, minX, minY, midX, minY, radius);
		CGPathAddArcToPoint(path, NULL, maxX, minY, maxX, maxY, radius);
		CGPathAddLineToPoint(path, NULL, maxX, maxY);
		CGPathAddLineToPoint(path, NULL, minX, maxY);
		CGPathCloseSubpath(path);
		CGContextAddPath(c, path);
		CGPathRelease(path);
		
		CGContextSaveGState(c);
		CGContextClip(c);
		UIImage *currentBackgroundImage = nil;
		
		if ([cell selectionStyle]==UITableViewCellSelectionStyleBlue) {
			currentBackgroundImage = [UIImage _tableSelection];
		}
		else {
			currentBackgroundImage = [UIImage _tableSelectionGray];
		}
		[currentBackgroundImage drawInRect:imageRect];
		CGContextRestoreGState(c);
		
		CGMutablePathRef spath = CGPathCreateMutable();
		CGPathMoveToPoint(spath, NULL, minX, maxY);
		CGPathAddArcToPoint(spath, NULL, minX, minY, midX, minY, radius);
		CGPathAddArcToPoint(spath, NULL, maxX, minY, maxX, maxY, radius);
		CGPathAddLineToPoint(spath, NULL, maxX, maxY);
		CGContextAddPath(c, spath);
		CGPathRelease(spath);
		CGContextSaveGState(c);
		CGContextSetRGBStrokeColor(c, .67f, .67f, .67f, 1.0);
		CGContextStrokePath(c);
		CGContextRestoreGState(c);
		
	}	
	else if ([cell sectionLocation]==UITableViewCellSectionLocationBottom) {
		
		CGContextClearRect(c, rect);
		
		CGRect imageRect = self.bounds;
		
		CGMutablePathRef path = CGPathCreateMutable();
		CGPathMoveToPoint(path, NULL, minX, minY-1.0f);
		CGPathAddArcToPoint(path, NULL, minX, maxY-1.0f, midX, maxY-1.0f, radius);
		CGPathAddArcToPoint(path, NULL, maxX, maxY-1.0f, maxX, minY-1.0f, radius);
		CGPathAddLineToPoint(path, NULL, maxX, minY-1.0f);
		CGPathAddLineToPoint(path, NULL, minX, minY-1.0f);
		CGPathCloseSubpath(path);
		CGContextAddPath(c, path);
		CGPathRelease(path);
		CGContextSaveGState(c);
		CGContextClip(c);
		UIImage *currentBackgroundImage = nil;
		if ([cell selectionStyle] == UITableViewCellSelectionStyleBlue) {
			currentBackgroundImage = [UIImage _tableSelection];
		}
		else {
			currentBackgroundImage = [UIImage _tableSelectionGray];
		}
		[currentBackgroundImage drawInRect:imageRect];
		CGContextRestoreGState(c);
		
		CGContextBeginPath(c);
		CGContextMoveToPoint(c, minX,minY-1.0f);
		CGContextAddArcToPoint(c,minX, maxY-1.0f, midX, maxY, radius);
		CGContextAddArcToPoint(c,maxX, maxY-1.0f, maxX, minY-1.0f, radius);
		CGContextAddLineToPoint(c, maxX, minY-1.0f);
		CGContextSaveGState(c);
		CGContextSetRGBStrokeColor(c, .67f, .67f, .67f, 1.0);
		CGContextStrokePath(c);
		CGContextRestoreGState(c);
		
	}
	else {
		
		CGContextSaveGState(c);
        
		CGRect imageRect = self.bounds;
		
		UIImage *currentBackgroundImage = nil;
		if ([cell selectionStyle] == UITableViewCellSelectionStyleBlue) {
			currentBackgroundImage = [UIImage _tableSelection];
		}
		else {
			currentBackgroundImage = [UIImage _tableSelectionGray];
		}
		[currentBackgroundImage drawInRect:imageRect];
		CGContextRestoreGState(c);
		
		CGContextBeginPath(c);
		CGContextMoveToPoint(c, minX,minY-1.0f);
		CGContextAddLineToPoint(c, minX, maxY+1.0f);
		
		CGContextSaveGState(c);
		CGContextSetRGBStrokeColor(c, .67f, .67f, .67f, 1.0);
		CGContextStrokePath(c);
		CGContextRestoreGState(c);
		
		CGContextBeginPath(c);
		CGContextMoveToPoint(c, maxX,minY-1.0f);
		CGContextAddLineToPoint(c, maxX, maxY+1.0f);
		
		CGContextSaveGState(c);
		CGContextSetRGBStrokeColor(c, .67f, .67f, .67f, 1.0);
		CGContextStrokePath(c);
		CGContextRestoreGState(c);
		
	}
}
@end

