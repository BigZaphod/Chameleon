#import "UITableViewCellLayoutManager.h"


@implementation UITableViewCellLayoutManager



+ (id) layoutManagerForTableViewCellStyle:(UITableViewCellStyle)style
{
    switch (style) {
        case UITableViewCellStyleDefault: break;
        case UITableViewCellStyleSubtitle: break;
        case UITableViewCellStyleValue1: break;
        case UITableViewCellStyleValue2: break;
    }
    assert(NO);
    return nil;
}

@end
