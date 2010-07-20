//  Created by Sean Heber on 6/4/10.
#import <Foundation/Foundation.h>

@interface NSIndexPath (UITableView)
+ (NSIndexPath *)indexPathForRow:(NSUInteger)row inSection:(NSUInteger)section;
@property (readonly) NSUInteger row;
@property (readonly) NSUInteger section;
@end
