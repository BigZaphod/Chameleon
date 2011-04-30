//
//  UITableViewCellBackgroundView.m
//  UIKit
//
//  Created by Stéphane BARON on 29/04/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "UITableViewCellBackgroundView.h"

@implementation UITableViewCellBackgroundView

@synthesize position;

- (void)drawRect:(CGRect)rect
{
	
	NSLog(@"DR");
	const CGRect bounds = self.bounds;
	
	CGFloat minX = CGRectGetMinX(rect), midX = CGRectGetMidX(rect), maxX = CGRectGetMaxX(rect);
	CGFloat minY = CGRectGetMinY(rect), midY = CGRectGetMidY(rect), maxY = CGRectGetMaxY(rect);
	
	float radius = 10;
	
	int lineWidth = 1;
	
	/*
	 CGRect rect = [self bounds];
	 rect.size.width -= lineWidth;
	 rect.size.height -= lineWidth;
	 rect.origin.x += lineWidth / 2.0;
	 rect.origin.y += lineWidth / 2.0;
	 */
	
	maxY += 1;
	
	CGContextRef c = UIGraphicsGetCurrentContext();
	CGColorSpaceRef myColorspace = CGColorSpaceCreateDeviceRGB();
	CGGradientRef blueGradient = nil;
	CGFloat locations[2] = { 0.0, 1.0 };
	CGFloat components[8] = { 0.81, 0.81, 0.81, 1.0,  // Start color
		0.67, 0.67, 0.67, 1.0 }; // End color
	
	CGContextSetStrokeColorWithColor(c, [[UIColor grayColor] CGColor]);
	CGContextSetLineWidth(c, lineWidth);
	CGContextSetAllowsAntialiasing(c, YES);
	CGContextSetShouldAntialias(c, YES);

	if (self.position==UITableViewCellPositionTop) 
	{
		CGContextSetRGBStrokeColor(c, .67f, .67f, .67f, 1.0);
		CGContextBeginPath(c);
		CGContextMoveToPoint(c, minX,maxY);
		CGContextAddArcToPoint(c,minX, minY, midX, minY, radius);
		CGContextAddArcToPoint(c,maxX, minY, maxX, maxY, radius);
		CGContextAddLineToPoint(c, maxX, maxY);
		//CGContextStrokePath(c);
		NSLog(@"bc %@",self.backgroundColor);
		CGContextSetFillColor(c,CGColorGetComponents(self.backgroundColor.CGColor));
		CGContextDrawPath(c, kCGPathFillStroke);
		
	}
}

@end

