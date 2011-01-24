//  Created by Sean Heber on 6/29/10.
#import "UIGestureRecognizer.h"

@interface UITapGestureRecognizer : UIGestureRecognizer {
	NSUInteger _numberOfTapsRequired;
	NSUInteger _numberOfTouchesRequired;
}

@property (nonatomic) NSUInteger numberOfTapsRequired;
@property (nonatomic) NSUInteger numberOfTouchesRequired;

@end
