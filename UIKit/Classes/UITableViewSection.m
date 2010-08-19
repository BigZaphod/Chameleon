//  Created by Sean Heber on 8/19/10.
#import "UITableViewSection.h"

@implementation UITableViewSection
@synthesize rowsHeight, headerHeight, footerHeight, rowHeights, numberOfRows, headerView, footerView, headerTitle, footerTitle;

- (CGFloat)sectionHeight
{
	return rowsHeight + headerHeight + footerHeight;
}

- (void)dealloc
{
	[headerView release];
	[footerView release];
	[rowHeights release];
	[headerTitle release];
	[footerTitle release];
	[super dealloc];
}
@end
