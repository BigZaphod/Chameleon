//  Created by Sean Heber on 12/16/10.
#import "UIPageControl.h"

@implementation UIPageControl
@synthesize currentPage=_currentPage, numberOfPages=_numberOfPages;

- (void)setCurrentPage:(NSInteger)page
{
	if (page != _currentPage) {
		_currentPage = MIN(MAX(0,page), self.numberOfPages-1);
		[self setNeedsDisplay];
	}
}

@end
