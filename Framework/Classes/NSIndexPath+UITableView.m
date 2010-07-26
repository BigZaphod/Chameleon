//  Created by Sean Heber on 6/4/10.
#import "NSIndexPath+UITableView.h"

@implementation NSIndexPath (UITableView)

+ (NSIndexPath *)indexPathForRow:(NSUInteger)row inSection:(NSUInteger)section
{
	NSUInteger path[2] = {section, row};
	return [self indexPathWithIndexes:path length:2];
}

- (NSUInteger)row
{
	return [self indexAtPosition:1];
}

-(NSUInteger)section
{
	return [self indexAtPosition:0];
}

@end
