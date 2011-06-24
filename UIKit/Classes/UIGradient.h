//
//  UIGradient.h
//  UIKit
//
//  Created by Josh Abernathy on 5/20/11.
//  Copyright 2011 Maybe Apps, LLC. All rights reserved.
//

#import "UIColor.h"


@interface UIGradient : NSObject {
	CGGradientRef _gradient;
}

- (id)initWithStartingColor:(UIColor *)starting endingColor:(UIColor *)ending;
- (id)initWithColors:(NSArray *)colors locations:(NSArray *)locations;

- (void)fillRect:(CGRect)rect;

@end
