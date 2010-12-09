//  Created by Sean Heber on 6/25/10.
#import "UIActivityIndicatorView.h"
#import "UIImage.h"
#import "UIGraphics.h"
#import "UIColor.h"
#import "UIFont.h"
#import "UIStringDrawing.h"
#import "UIBezierPath.h"
#import <QuartzCore/QuartzCore.h>

static CGSize UIActivityIndicatorViewStyleSize(UIActivityIndicatorViewStyle style)
{
	if (style == UIActivityIndicatorViewStyleWhiteLarge) {
		return CGSizeMake(37,37);
	} else {
		return CGSizeMake(20,20);
	}
}

static UIImage *UIActivityIndicatorViewFrameImage(UIActivityIndicatorViewStyle style, NSInteger frame, NSInteger numberOfFrames)
{
	const CGSize frameSize = UIActivityIndicatorViewStyleSize(style);
	const CGFloat radius = frameSize.width / 2.f;
	const CGFloat TWOPI = M_PI * 2.f;
	const CGFloat numberOfTeeth = 12;
	const CGFloat toothWidth = (style == UIActivityIndicatorViewStyleWhiteLarge)? 3 : 2;

	UIColor *toothColor = (style == UIActivityIndicatorViewStyleGray)? [UIColor grayColor] : [UIColor whiteColor];
	
	UIGraphicsBeginImageContext(frameSize);
	CGContextRef c = UIGraphicsGetCurrentContext();

	// first put the origin in the center of the frame. this makes things easier later
	CGContextTranslateCTM(c, radius, radius);

	// now rotate the entire thing depending which frame we're trying to generate
	CGContextRotateCTM(c, frame / (CGFloat)numberOfFrames * TWOPI);

	// draw all the teeth
	for (NSInteger toothNumber=0; toothNumber<numberOfTeeth; toothNumber++) {
		// set the correct color for the tooth, dividing by more than the number of teeth to prevent the last tooth from being too translucent
		const CGFloat alpha = 0.3 + ((toothNumber / numberOfTeeth) * 0.7);
		[[toothColor colorWithAlphaComponent:alpha] setFill];
		
		// position and draw the tooth
		CGContextRotateCTM(c, 1 / numberOfTeeth * TWOPI);
		[[UIBezierPath bezierPathWithRoundedRect:CGRectMake(-toothWidth/2.f,-radius,toothWidth,ceilf(radius*.54f)) cornerRadius:toothWidth/2.f] fill];
	}
	
	// hooray!
	UIImage *frameImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	return frameImage;
}

@implementation UIActivityIndicatorView
@synthesize hidesWhenStopped=_hidesWhenStopped, activityIndicatorViewStyle=_activityIndicatorViewStyle;

- (id)initWithActivityIndicatorStyle:(UIActivityIndicatorViewStyle)style
{
	CGRect frame = CGRectZero;
	frame.size = UIActivityIndicatorViewStyleSize(style);
	
	if ((self=[super initWithFrame:frame])) {
		_animating = NO;
		self.activityIndicatorViewStyle = style;
		self.hidesWhenStopped = YES;
		self.opaque = NO;
	}

	return self;
}

- (id)initWithFrame:(CGRect)frame
{
	if ((self = [self initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite])) {
		self.frame = frame;
	}

	return self;
}

- (CGSize)sizeThatFits:(CGSize)aSize
{
	return UIActivityIndicatorViewStyleSize(_activityIndicatorViewStyle);
}

- (void)setActivityIndicatorViewStyle:(UIActivityIndicatorViewStyle)style
{
	if (_activityIndicatorViewStyle != style) {
		_activityIndicatorViewStyle = style;
		[self setNeedsDisplay];
		
		if (_animating) {
			[self startAnimating];	// this will reset the images in the animation if it was already animating
		}
	}
}

- (void)setHidesWhenStopped:(BOOL)hides
{
	_hidesWhenStopped = hides;

	if (_hidesWhenStopped) {
		self.hidden = !_animating;
	} else {
		self.hidden = NO;
	}
}

- (void)startAnimating
{
	_animating = YES;
	self.hidden = NO;
	
	const NSInteger numberOfFrames = 12;
	const CFTimeInterval animationDuration = 0.8;
	
	NSMutableArray *images = [[NSMutableArray alloc] initWithCapacity:numberOfFrames];
	
	for (NSInteger frameNumber=0; frameNumber<numberOfFrames; frameNumber++) {
		[images addObject:(id)UIActivityIndicatorViewFrameImage(_activityIndicatorViewStyle, frameNumber, numberOfFrames).CGImage];
	}
	
	CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"contents"];
	animation.calculationMode = kCAAnimationDiscrete;
	animation.duration = animationDuration;
	animation.repeatCount = HUGE_VALF;
	animation.values = images;
	
	[self.layer addAnimation:animation forKey:@"contents"];
	
	[images release];	
}

- (void)stopAnimating
{
	_animating = NO;
	[self.layer removeAnimationForKey:@"contents"];
	
	if (self.hidesWhenStopped) {
		self.hidden = YES;
	}
}

- (BOOL)isAnimating
{
	return _animating;
}

- (void)drawRect:(CGRect)rect
{
	[UIActivityIndicatorViewFrameImage(_activityIndicatorViewStyle, 0, 1) drawInRect:self.bounds];
}

@end
