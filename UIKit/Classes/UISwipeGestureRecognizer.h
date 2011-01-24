//  Created by Sean Heber on 1/24/11.
#import "UIGestureRecognizer.h"

typedef enum {
	UISwipeGestureRecognizerDirectionRight = 1 << 0,
	UISwipeGestureRecognizerDirectionLeft  = 1 << 1,
	UISwipeGestureRecognizerDirectionUp    = 1 << 2,
	UISwipeGestureRecognizerDirectionDown  = 1 << 3
} UISwipeGestureRecognizerDirection;

@interface UISwipeGestureRecognizer : UIGestureRecognizer {
	UISwipeGestureRecognizerDirection _direction;
	NSUInteger _numberOfTouchesRequired;
}

@property (nonatomic) UISwipeGestureRecognizerDirection direction;
@property (nonatomic) NSUInteger numberOfTouchesRequired;

@end
