//  Created by Sean Heber on 1/24/11.
#import "UIGestureRecognizer.h"

@interface UIRotationGestureRecognizer : UIGestureRecognizer {
	CGFloat _rotation;
}

@property (nonatomic) CGFloat rotation;
@property (nonatomic,readonly) CGFloat velocity;

@end
