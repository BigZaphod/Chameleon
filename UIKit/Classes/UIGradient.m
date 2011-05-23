//
//  UIGradient.m
//  UIKit
//
//  Created by Josh Abernathy on 5/20/11.
//  Copyright 2011 Maybe Apps, LLC. All rights reserved.
//

#import "UIGradient.h"
#import "UIGraphics.h"


@implementation UIGradient


#pragma mark API

- (void)dealloc {
	CGGradientRelease(_gradient);
	
	[super dealloc];
}

- (void)finalize {
	CGGradientRelease(_gradient);
	
	[super finalize];
}

- (id)initWithStartingColor:(UIColor *)starting endingColor:(UIColor *)ending {
	self = [super init];
	if(self == nil) {
		[self release];
		return nil;
	}
	
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	CGFloat locations[2];
	locations[0] = 1.0f;
	locations[1] = 0.0f;
	_gradient = CGGradientCreateWithColors(colorSpace, (CFArrayRef) [NSArray arrayWithObjects:(id) starting.CGColor, (id) ending.CGColor, nil], locations);
	CGColorSpaceRelease(colorSpace);
	
	return self;
}

- (id)initWithColors:(NSArray *)colors locations:(NSArray *)colorLocations {
	self = [super init];
	if(self == nil) {
		[self release];
		return nil;
	}
	
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	CGFloat locations[colorLocations.count];
	NSUInteger index = 0;
	for(NSNumber *location in colorLocations) {
		locations[index] = (CGFloat) [location doubleValue];
		
		index++;
	}
	
	NSMutableArray *cgColors = [NSMutableArray arrayWithCapacity:colors.count];
	for(UIColor *color in colors) {
		[cgColors addObject:(id) color.CGColor];
	}
	
	_gradient = CGGradientCreateWithColors(colorSpace, (CFArrayRef) cgColors, locations);
	CGColorSpaceRelease(colorSpace);
	
	return self;
}

- (void)fillRect:(CGRect)rect {
	CGContextDrawLinearGradient(UIGraphicsGetCurrentContext(), _gradient, CGPointMake(CGRectGetMinX(rect), CGRectGetMinY(rect)), CGPointMake(CGRectGetMinX(rect), CGRectGetMaxY(rect)), 0);
}

@end
