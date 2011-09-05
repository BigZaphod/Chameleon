//
//  UIRed.m
//  TestTable
//
//  Created by Stéphane BARON on 05/05/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "UIRed.h"


@implementation UIRed


- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code.
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code.
	[[UIColor redColor] set];
	UIRectFill(rect);
}


- (void)dealloc {
    [super dealloc];
}


@end
