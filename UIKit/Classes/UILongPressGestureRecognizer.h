//  Created by Sean Heber on 6/29/10.
#import "UIGestureRecognizer.h"

@interface UILongPressGestureRecognizer : UIGestureRecognizer {
@private
	CFTimeInterval _minimumPressDuration;
	CGFloat _allowableMovement;
	NSUInteger _numberOfTapsRequired;
	NSInteger _numberOfTouchesRequired;
}

@property (nonatomic) CFTimeInterval minimumPressDuration;
@property (nonatomic) CGFloat allowableMovement;
@property (nonatomic) NSUInteger numberOfTapsRequired;
@property (nonatomic) NSInteger numberOfTouchesRequired;

@end
