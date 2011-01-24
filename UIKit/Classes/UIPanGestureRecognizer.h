//  Created by Sean Heber on 1/24/11.
#import "UIGestureRecognizer.h"

@interface UIPanGestureRecognizer : UIGestureRecognizer {
	NSUInteger _maximumNumberOfTouches;
	NSUInteger _minimumNumberOfTouches;
}

- (CGPoint)translationInView:(UIView *)view;
- (void)setTranslation:(CGPoint)translation inView:(UIView *)view;
- (CGPoint)velocityInView:(UIView *)view;

@property (nonatomic) NSUInteger maximumNumberOfTouches;
@property (nonatomic) NSUInteger minimumNumberOfTouches;

@end
