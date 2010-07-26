//  Created by Sean Heber on 6/29/10.
#import "UIGestureRecognizer.h"

@interface UILongPressGestureRecognizer : UIGestureRecognizer {
@private
	CFTimeInterval _minimumPressDuration;
}

@property (nonatomic) CFTimeInterval minimumPressDuration;

@end
