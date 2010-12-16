//  Created by Sean Heber on 12/16/10.
#import "UIControl.h"


@interface UIPageControl : UIControl {
	NSInteger _currentPage;
	NSInteger _numberOfPages;
}

@property (nonatomic) NSInteger currentPage;
@property (nonatomic) NSInteger numberOfPages;

@end
