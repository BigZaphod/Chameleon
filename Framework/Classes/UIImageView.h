//  Created by Sean Heber on 5/27/10.
#import "UIView.h"

@class UIImage, CAKeyframeAnimation;

@interface UIImageView : UIView {
@private
	UIImage *_image;
	NSArray *_animationImages;
	NSArray *_highlightedAnimationImages;
	NSTimeInterval _animationDuration;
	NSInteger _animationRepeatCount;
	UIImage *_highlightedImage;
	BOOL _highlighted;
}

- (id)initWithImage:(UIImage *)theImage;
- (void)startAnimating;
- (void)stopAnimating;
- (BOOL)isAnimating;

@property (nonatomic, retain) UIImage *highlightedImage;
@property (nonatomic, getter=isHighlighted) BOOL highlighted;

@property (nonatomic, retain) UIImage *image;
@property (nonatomic, copy) NSArray *animationImages;
@property (nonatomic, copy) NSArray *highlightedAnimationImages;
@property (nonatomic) NSTimeInterval animationDuration;
@property (nonatomic) NSInteger animationRepeatCount;

@end
