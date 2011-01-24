//  Created by Sean Heber on 1/24/11.
#import "UIGestureRecognizer.h"

@interface UIPinchGestureRecognizer : UIGestureRecognizer {
	CGFloat _scale;
}

@property (nonatomic) CGFloat scale;
@property (nonatomic, readonly) CGFloat velocity;

@end
