//  Created by Sean Heber on 6/2/10.
#import "_UIViewLayoutManager.h"
#import "UIView+UIPrivate.h"

static _UIViewLayoutManager *theLayoutManager = nil;

@implementation _UIViewLayoutManager

+ (void)initialize
{
	if (self == [_UIViewLayoutManager class]) {
		theLayoutManager = [self new];
	}
}

+ (_UIViewLayoutManager *)layoutManager
{
	return theLayoutManager;
}

- (void)layoutSublayersOfLayer:(CALayer *)theLayer
{
	if ([[theLayer delegate] respondsToSelector:@selector(_layoutSubviews)]) {
		[[theLayer delegate] _layoutSubviews];
	}
}

@end
