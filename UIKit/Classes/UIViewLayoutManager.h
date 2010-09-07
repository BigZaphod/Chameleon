//  Created by Sean Heber on 6/2/10.
#import <Foundation/Foundation.h>

@protocol UIViewLayoutManagerProtocol <NSObject>
- (void)layoutSubviews;
@end

@interface UIViewLayoutManager : NSObject
+ (UIViewLayoutManager *)layoutManager;
@end
