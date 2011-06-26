//
//  UIGreen.m
//  NavBarTableView
//
//  Created by Stéphane BARON on 29/05/11.
//  Copyright 2011 MintK. All rights reserved.
//

#import "UIGreen.h"


@implementation UIGreen
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
	[[UIColor greenColor] set];
	UIRectFill(rect);
}


- (void)dealloc {
    [super dealloc];
}


@end