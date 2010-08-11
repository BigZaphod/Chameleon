//  Created by Sean Heber on 5/27/10.
#import "UIView+UIPrivate.h"
#import "CALayer+UIPrivate.h"
#import "UIWindow.h"
#import "UIGraphics.h"
#import "UIColor.h"
#import "_UIViewLayoutManager.h"
#import "_UIViewAnimationGroup.h"
#import "UIViewController.h"

static NSMutableArray *_animationGroups;
static BOOL _animationsEnabled = YES;

@implementation UIView
@synthesize layer=_layer, subviews=_subviews, superview=_superview, clearsContextBeforeDrawing=_clearsContextBeforeDrawing, autoresizesSubviews=_autoresizesSubviews;
@synthesize tag=_tag, userInteractionEnabled=_userInteractionEnabled, contentMode=_contentMode, backgroundColor=_backgroundColor;
@synthesize multipleTouchEnabled=_multipleTouchEnabled, exclusiveTouch=_exclusiveTouch, autoresizingMask=_autoresizingMask;

+ (void)initialize
{
	if (self == [UIView class]) {
		_animationGroups = [NSMutableArray new];
	}
}

+ (Class)layerClass
{
	return [CALayer class];
}

+ (BOOL)_instanceImplementsDrawRect
{
	return [UIView instanceMethodForSelector:@selector(drawRect:)] != [self instanceMethodForSelector:@selector(drawRect:)];
}

- (id)init
{
	return [self initWithFrame:CGRectZero];
}

- (id)initWithFrame:(CGRect)theFrame
{
	if ((self=[super init])) {
		_implementsDrawRect = [isa _instanceImplementsDrawRect];

		_subviews = [NSMutableArray new];
		_layer = [[[[self class] layerClass] alloc] init];
		_layer.delegate = self;
		_layer.layoutManager = [_UIViewLayoutManager layoutManager];

		self.frame = theFrame;
		self.alpha = 1;
		self.clearsContextBeforeDrawing = YES;
		self.opaque = YES;
		self.autoresizesSubviews = YES;
		self.userInteractionEnabled = YES;
		[self setNeedsDisplay];
	}
	return self;
}

- (void)dealloc
{
	[_subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
	[_subviews release];
	_layer.layoutManager = nil;
	_layer.delegate = nil;
	[_layer release];
	[super dealloc];
}

- (void)_setViewController:(UIViewController *)theViewController
{
	_viewController = theViewController;
}

- (UIWindow *)window
{
	return _superview.window;
}

- (UIResponder *)nextResponder
{
	// NOTE: Once view controllers are implemented, this should return the view controller that owns this view (if there is one)
	// and then the view controller itself would return this view's superview instead (this inserts the controller into the chain)
	return _viewController ? (UIResponder *)_viewController : (UIResponder *)_superview;
}

- (NSArray *)subviews
{
	return [[_subviews copy] autorelease];
}

- (void)insertSubview:(UIView *)subview atIndex:(NSInteger)index
{
	// this isn't exactly right - see notes in insertSubview:below: for why.

	if (subview && subview.superview != self) {
		const BOOL changingWindows = (subview.window != self.window);
		
		if (subview->_viewController) [subview->_viewController viewWillAppear:NO];
		if (changingWindows) [subview willMoveToWindow:self.window];
		[subview willMoveToSuperview:self];
		
		[subview retain];
		if (subview.superview) {
			[subview.layer removeFromSuperlayer];
			[subview.superview->_subviews removeObject:subview];
		}
		[_subviews insertObject:subview atIndex:index];
		subview->_superview = self;
		[_layer insertSublayer:subview.layer atIndex:index];
		[subview release];
		
		if (subview->_viewController) [subview->_viewController viewDidAppear:NO];
		if (changingWindows) [subview didMoveToWindow];
		[subview didMoveToSuperview];
		
		[subview _hierarchyPositionDidChange];
		
		[self didAddSubview:subview];
	}
}

- (void)addSubview:(UIView *)subview
{
	[self insertSubview:subview atIndex:[_subviews count]];
}

- (void)insertSubview:(UIView *)subview belowSubview:(UIView *)below
{
	// This doesn't work right because if the subview is already a subview, this has no effect.
	// I don't think it's right to just remove it and re-add it. This needs to be more clever.
	// Note that the same problem would apply to insertSubview:atIndex: which is assumed to
	// move the subview (even if it is already added) to the proper index.
	[self insertSubview:subview atIndex:[_subviews indexOfObject:below]];
}

- (void)removeFromSuperview
{
	if (_superview) {
		[self retain];
		if (_viewController) [_viewController viewWillDisappear:NO];
		[_superview willRemoveSubview:self];
		[self willMoveToWindow:nil];
		[self willMoveToSuperview:nil];
		[_layer removeFromSuperlayer];
		[_superview->_subviews removeObject:self];
		_superview = nil;
		if (_viewController) [_viewController viewDidDisappear:NO];
		[self didMoveToWindow];
		[self didMoveToSuperview];
		[self _hierarchyPositionDidChange];
		[self release];
	}
}

- (void)bringSubviewToFront:(UIView *)subview
{
	if (subview.superview == self) {
		[subview retain];
		[_subviews removeObject:subview];
		[_subviews addObject:subview];
		[subview release];
		[_layer insertSublayer:subview.layer above:[[_layer sublayers] lastObject]];
	}
}

- (void)sendSubviewToBack:(UIView *)subview
{
	if (subview.superview == self) {
		[subview retain];
		[_subviews removeObject:subview];
		[_subviews insertObject:subview atIndex:0];
		[subview release];
		[_layer insertSublayer:subview.layer atIndex:0];
	}
}

- (void)didAddSubview:(UIView *)subview
{
}

- (void)didMoveToSuperview
{
}

- (void)didMoveToWindow
{
}

- (void)willMoveToSuperview:(UIView *)newSuperview
{
}

- (void)willMoveToWindow:(UIWindow *)newWindow
{
}

- (void)willRemoveSubview:(UIView *)subview
{
}

- (CGPoint)convertPoint:(CGPoint)toConvert fromView:(UIView *)fromView
{
	if (fromView) {
		// If the screens are the same, then we know they share a common parent CALayer, so we can convert directly with the layer's
		// conversion method. If not, though, we need to do something a bit more complicated.
		if (fromView && (self.window.screen == fromView.window.screen)) {
			return [fromView.layer convertPoint:toConvert toLayer:self.layer];
		} else {
			// Convert coordinate to fromView's window base coordinates.
			toConvert = [fromView.layer convertPoint:toConvert toLayer:fromView.window.layer];
			
			// Now convert from fromView's window to our own window.
			toConvert = [fromView.window convertPoint:toConvert toWindow:self.window];
		}
	}

	// Convert from our window coordinate space into our own coordinate space.
	return [self.window.layer convertPoint:toConvert toLayer:self.layer];
}

- (CGPoint)convertPoint:(CGPoint)toConvert toView:(UIView *)toView
{
	// See note in convertPoint:fromView: for some explaination about why this is done... :/
	if (toView && (self.window.screen == toView.window.screen)) {
		return [self.layer convertPoint:toConvert toLayer:toView.layer];
	} else {
		// Convert to our window's coordinate space.
		toConvert = [self.layer convertPoint:toConvert toLayer:self.window.layer];
		
		if (toView) {
			// Convert from one window's coordinate space to another.
			toConvert = [self.window convertPoint:toConvert toWindow:toView.window];
			
			// Convert from toView's window down to toView's coordinate space.
			toConvert = [toView.window.layer convertPoint:toConvert toLayer:toView.layer];
		}
		
		return toConvert;
	}
}

- (CGRect)convertRect:(CGRect)toConvert fromView:(UIView *)fromView
{
	CGPoint origin = [self convertPoint:CGPointMake(CGRectGetMinX(toConvert),CGRectGetMinY(toConvert)) fromView:fromView];
	CGPoint bottom = [self convertPoint:CGPointMake(CGRectGetMaxX(toConvert),CGRectGetMaxY(toConvert)) fromView:fromView];
	return CGRectMake(origin.x, origin.y, bottom.x-origin.x, bottom.y-origin.y);
}

- (CGRect)convertRect:(CGRect)toConvert toView:(UIView *)toView
{
	CGPoint origin = [self convertPoint:CGPointMake(CGRectGetMinX(toConvert),CGRectGetMinY(toConvert)) toView:toView];
	CGPoint bottom = [self convertPoint:CGPointMake(CGRectGetMaxX(toConvert),CGRectGetMaxY(toConvert)) toView:toView];
	return CGRectMake(origin.x, origin.y, bottom.x-origin.x, bottom.y-origin.y);
}

- (void)sizeToFit
{
	CGRect frame = self.frame;
	frame.size = [self sizeThatFits:frame.size];
	self.frame = frame;
}

- (CGSize)sizeThatFits:(CGSize)size
{
	return size;
}

- (UIView *)viewWithTag:(NSInteger)tagToFind
{
	UIView *foundView = nil;
	
	if (self.tag == tagToFind) {
		foundView = self;
	} else {
		for (UIView *view in self.subviews) {
			foundView = [view viewWithTag:tagToFind];
			if (foundView)
				break;
		}
	}
	
	return foundView;
}

- (void)setNeedsDisplay
{
	[_layer setNeedsDisplay];
}

- (void)setNeedsDisplayInRect:(CGRect)invalidRect
{
	[_layer setNeedsDisplayInRect:invalidRect];
}

- (void)drawRect:(CGRect)rect
{
}

- (void)displayLayer:(CALayer *)theLayer
{
	// Okay, this is some crazy stuff right here. Basically, the real UIKit avoids creating any contents for its layer if there's no drawRect:
	// specified in the UIView's subview. This nicely prevents a ton of useless memory usage and likley improves performance a lot on iPhone.
	// It took great pains to discover this trick and I think I'm doing this right. By having this method empty here, it means that it overrides
	// the layer's normal display method and instead does nothing which results in the layer not making a backing store and wasting memory.
	
	// Here's how CALayer appears to work:
	// 1- something call's the layer's -display method.
	// 2- arrive in CALayer's display: method.
	// 2a-  if delegate implements displayLayer:, call that.
	// 2b-  if delegate doesn't implement displayLayer:, CALayer creates a buffer and a context and passes that to drawInContext:
	// 3- arrive in CALayer's drawInContext: method.
	// 3a-  if delegate implements drawLayer:inContext:, call that and pass it the context.
	// 3b-  otherwise, does nothing
	
	// So, what this all means is that to avoid causing the CALayer to create a context and use up memory, our delegate has to lie to CALayer
	// about if it implements displayLayer: or not. If we say it does, we short circuit the layer's buffer creation process (since it assumes
	// we are going to be setting it's contents property ourselves). So, that's what we do in the override of respondsToSelector: below.
	
	// backgroundColor is influenced by all this as well. If drawRect: is defined, we draw it directly in the context so that blending is all
	// pretty and stuff. If it isn't, though, we still want to support it. What the real UIKit does is it sets the layer's backgroundColor
	// iff drawRect: isn't specified. Otherwise it manages it itself. Again, this is for performance reasons. Rather than having to store a
	// whole bitmap the size of view just to hold the backgroundColor, this allows a lot of views to simply act as containers and not waste
	// a bunch of unnecessary memory in those cases - but you can still use background colors because CALayer manages that effeciently.
	
	// Clever, huh?
}

- (BOOL)respondsToSelector:(SEL)aSelector
{
	// For notes about why this is done, see displayLayer: above.
	if (aSelector == @selector(displayLayer:)) {
		return !_implementsDrawRect;
	} else {
		return [super respondsToSelector:aSelector];
	}
}

- (void)drawLayer:(CALayer *)layer inContext:(CGContextRef)ctx
{
	// We only get here if the UIView subclass implements drawRect:. To do this without a drawRect: is a huge waste of memory.
	// See the discussion in drawLayer: above.

	const CGRect bounds = CGContextGetClipBoundingBox(ctx);

	UIGraphicsPushContext(ctx);
	CGContextSaveGState(ctx);
	
	if (_clearsContextBeforeDrawing) {
		CGContextClearRect(ctx, bounds);
	}

	if (_backgroundColor) {
		[_backgroundColor setFill];
		CGContextFillRect(ctx,bounds);
	}

	// Font smoothing looks really bad (or just plain doesn't work, I don't know which) if the background color is transparent
	// or has any amount of transparency in it. This solves that problem.
	const BOOL shouldSmoothFonts = (_backgroundColor && (CGColorGetAlpha(_backgroundColor.CGColor) == 1));
	CGContextSetShouldSmoothFonts(ctx, shouldSmoothFonts);
	
	[[UIColor blackColor] set];
	[self drawRect:bounds];

	CGContextRestoreGState(ctx);
	UIGraphicsPopContext();
}

- (id)actionForLayer:(CALayer *)theLayer forKey:(NSString *)event
{
	if (_animationsEnabled && [_animationGroups lastObject]) {
		NSSet *animatableKeys = [NSSet setWithObjects:@"bounds", @"position", @"zPosition", @"anchorPoint", @"transform", @"sublayerTransform",
								 @"contents", @"contentsRect", @"contentsCenter", @"opacity", @"hidden", @"masksToBounds", @"doubleSided", @"cornerRadius",
								 @"borderWidth", @"borderColor", @"backgroundColor", @"backgroundFilters", @"shadowOpacity", @"shadowRadius", @"shadowOffset",
								 @"shadowColor", @"filters", @"compositingFilter", nil];
		
		const BOOL isAnimatable = [animatableKeys containsObject:[[event componentsSeparatedByString:@"."] objectAtIndex:0]];

		if (isAnimatable) {
			return [[_animationGroups lastObject] actionForLayer:theLayer forKey:event] ?: (id)[NSNull null];
		}
	}

	return [NSNull null];
}

- (void)_superviewSizeDidChangeFrom:(CGSize)oldSize to:(CGSize)newSize
{
	CGRect frame = self.frame;
	CGFloat widthChanges = 0;
	CGFloat heightChanges = 0;

	if (_autoresizingMask & UIViewAutoresizingFlexibleLeftMargin)	widthChanges++;
	if (_autoresizingMask & UIViewAutoresizingFlexibleWidth)		widthChanges++;
	if (_autoresizingMask & UIViewAutoresizingFlexibleRightMargin)	widthChanges++;

	if (_autoresizingMask & UIViewAutoresizingFlexibleTopMargin)	heightChanges++;
	if (_autoresizingMask & UIViewAutoresizingFlexibleHeight)		heightChanges++;
	if (_autoresizingMask & UIViewAutoresizingFlexibleBottomMargin)	heightChanges++;
	
	CGFloat widthDelta = (newSize.width-oldSize.width) / widthChanges;
	CGFloat heightDelta = (newSize.height-oldSize.height) / heightChanges;
	
	if (_autoresizingMask & UIViewAutoresizingFlexibleLeftMargin)	frame.origin.x += widthDelta;
	if (_autoresizingMask & UIViewAutoresizingFlexibleWidth)		frame.size.width += widthDelta;

	if (_autoresizingMask & UIViewAutoresizingFlexibleTopMargin)	frame.origin.y += heightDelta;
	if (_autoresizingMask & UIViewAutoresizingFlexibleHeight)		frame.size.height += heightDelta;
	
	self.frame = frame;
}

- (void)_boundsSizeDidChange
{
}

- (void)_boundsSizeDidChangeFrom:(CGSize)oldSize to:(CGSize)newSize
{
	if (!CGSizeEqualToSize(oldSize, newSize)) {
		[self _boundsSizeDidChange];
		if (_autoresizesSubviews) {
			for (UIView *subview in _subviews) {
				[subview _superviewSizeDidChangeFrom:oldSize to:newSize];
			}
		}
	}
}

- (void)_hierarchyPositionDidChange
{
	for (UIView *subview in _subviews) {
		[subview _hierarchyPositionDidChange];
	}
}

- (void)_positionDidChangeFrom:(CGPoint)oldPosition to:(CGPoint)newPosition
{
	if (!CGPointEqualToPoint(oldPosition,newPosition)) {
		[self _hierarchyPositionDidChange];
	}
}

- (CGRect)frame
{
	return _layer.frame;
}

- (void)setFrame:(CGRect)newFrame
{
	CGSize oldSize = _layer.bounds.size;
	CGPoint oldPosition = _layer.position;
	
	_layer.frame = newFrame;
	
	[self _boundsSizeDidChangeFrom:oldSize to:_layer.bounds.size];
	[self _positionDidChangeFrom:oldPosition to:_layer.position];
}

- (CGRect)bounds
{
	return _layer.bounds;
}

- (void)setBounds:(CGRect)newBounds
{
	CGSize oldSize = _layer.bounds.size;
	CGPoint oldPosition = _layer.position;

	_layer.bounds = newBounds;
	
	[self _boundsSizeDidChangeFrom:oldSize to:_layer.bounds.size];
	[self _positionDidChangeFrom:oldPosition to:_layer.position];
}

- (CGPoint)center
{
	return _layer.position;
}

- (void)setCenter:(CGPoint)newCenter
{
	CGPoint oldPosition = _layer.position;

	_layer.position = newCenter;

	[self _positionDidChangeFrom:oldPosition to:_layer.position];
}

- (CGAffineTransform)transform
{
	return _layer.affineTransform;
}

- (void)setTransform:(CGAffineTransform)transform
{
	_layer.affineTransform = transform;
}

- (CGFloat)alpha
{
	return _layer.opacity;
}

- (void)setAlpha:(CGFloat)newAlpha
{
	_layer.opacity = newAlpha;
}

- (BOOL)isOpaque
{
	return _layer.opaque;
}

- (void)setOpaque:(BOOL)newO
{
	_layer.opaque = newO;
}

- (void)setBackgroundColor:(UIColor *)newColor
{
	if (_backgroundColor != newColor) {
		[_backgroundColor release];
		_backgroundColor = [newColor retain];

		CGColorRef color = [_backgroundColor CGColor];

		if (color) {
			self.opaque = (CGColorGetAlpha(color) == 1);
		}
		
		if (!_implementsDrawRect) {
			_layer.backgroundColor = color;
		}
	}
}

- (BOOL)clipsToBounds
{
	return _layer.masksToBounds;
}

- (void)setClipsToBounds:(BOOL)clips
{
	_layer.masksToBounds = clips;
}

- (void)setContentStretch:(CGRect)rect
{
	_layer.contentsRect = rect;
}

- (CGRect)contentStretch
{
	return _layer.contentsRect;
}

- (void)setHidden:(BOOL)h
{
	_layer.hidden = h;
}

- (BOOL)isHidden
{
	return _layer.hidden;
}

- (void)setNeedsLayout
{
	[_layer setNeedsLayout];
}

- (void)layoutIfNeeded
{
	[_layer layoutIfNeeded];
}

- (void)layoutSubviews
{
}

- (void)_layoutSubviews
{
	[self layoutSubviews];
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
	return CGRectContainsPoint(self.bounds, point);
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
	if (![self pointInside:point withEvent:event]) {
		return nil;
	} else {
		for (UIView *subview in [self.subviews reverseObjectEnumerator]) {
			if (subview.userInteractionEnabled && subview.alpha >= 0.1 && !subview.hidden) {
				CGPoint subviewPoint = [subview convertPoint:point fromView:self];
				UIView *hitView = [subview hitTest:subviewPoint withEvent:event];
				if (hitView) return hitView;
			}
		}
		return self;
	}
}

- (void)setContentMode:(UIViewContentMode)mode
{
	if (mode != _contentMode) {
		_contentMode = mode;
		switch(_contentMode) {
			case UIViewContentModeScaleToFill:
				_layer.contentsGravity = kCAGravityResize;
				_layer.needsDisplayOnBoundsChange = NO;
				break;

			case UIViewContentModeScaleAspectFit:
				_layer.contentsGravity = kCAGravityResizeAspect;
				_layer.needsDisplayOnBoundsChange = NO;
				break;

			case UIViewContentModeScaleAspectFill:
				_layer.contentsGravity = kCAGravityResizeAspectFill;
				_layer.needsDisplayOnBoundsChange = NO;
				break;

			case UIViewContentModeRedraw:
				_layer.needsDisplayOnBoundsChange = YES;
				break;
				
			case UIViewContentModeCenter:
				_layer.contentsGravity = kCAGravityCenter;
				_layer.needsDisplayOnBoundsChange = NO;
				break;

			case UIViewContentModeTop:
				_layer.contentsGravity = kCAGravityTop;
				_layer.needsDisplayOnBoundsChange = NO;
				break;

			case UIViewContentModeBottom:
				_layer.contentsGravity = kCAGravityBottom;
				_layer.needsDisplayOnBoundsChange = NO;
				break;

			case UIViewContentModeLeft:
				_layer.contentsGravity = kCAGravityLeft;
				_layer.needsDisplayOnBoundsChange = NO;
				break;

			case UIViewContentModeRight:
				_layer.contentsGravity = kCAGravityRight;
				_layer.needsDisplayOnBoundsChange = NO;
				break;

			case UIViewContentModeTopLeft:
				_layer.contentsGravity = kCAGravityTopLeft;
				_layer.needsDisplayOnBoundsChange = NO;
				break;

			case UIViewContentModeTopRight:
				_layer.contentsGravity = kCAGravityTopRight;
				_layer.needsDisplayOnBoundsChange = NO;
				break;

			case UIViewContentModeBottomLeft:
				_layer.contentsGravity = kCAGravityBottomLeft;
				_layer.needsDisplayOnBoundsChange = NO;
				break;

			case UIViewContentModeBottomRight:
				_layer.contentsGravity = kCAGravityBottomRight;
				_layer.needsDisplayOnBoundsChange = NO;
				break;
		}
	}
}

- (void)addGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
{
}

+ (void)beginAnimations:(NSString *)animationID context:(void *)context
{
	[_animationGroups addObject:[_UIViewAnimationGroup animationGroupWithName:animationID context:context]];
}

+ (void)commitAnimations
{
	[[_animationGroups lastObject] commit];
	[_animationGroups removeLastObject];
}

+ (void)setAnimationBeginsFromCurrentState:(BOOL)beginFromCurrentState
{
	[[_animationGroups lastObject] setAnimationBeginsFromCurrentState:beginFromCurrentState];
}

+ (void)setAnimationCurve:(UIViewAnimationCurve)curve
{
	[[_animationGroups lastObject] setAnimationCurve:curve];
}

+ (void)setAnimationDelay:(NSTimeInterval)delay
{
	[[_animationGroups lastObject] setAnimationDelay:delay];
}

+ (void)setAnimationDelegate:(id)delegate
{
	[[_animationGroups lastObject] setAnimationDelegate:delegate];
}

+ (void)setAnimationDidStopSelector:(SEL)selector
{
	[[_animationGroups lastObject] setAnimationDidStopSelector:selector];
}

+ (void)setAnimationDuration:(NSTimeInterval)duration
{
	[[_animationGroups lastObject] setAnimationDuration:duration];
}

+ (void)setAnimationRepeatAutoreverses:(BOOL)repeatAutoreverses
{
	[[_animationGroups lastObject] setAnimationRepeatAutoreverses:repeatAutoreverses];
}

+ (void)setAnimationRepeatCount:(float)repeatCount
{
	[[_animationGroups lastObject] setAnimationRepeatCount:repeatCount];
}

+ (void)setAnimationWillStartSelector:(SEL)selector
{
	[[_animationGroups lastObject] setAnimationWillStartSelector:selector];
}

+ (void)setAnimationTransition:(UIViewAnimationTransition)transition forView:(UIView *)view cache:(BOOL)cache
{
	[[_animationGroups lastObject] setAnimationTransition:transition forView:view cache:cache];
}

+ (BOOL)areAnimationsEnabled
{
	return _animationsEnabled;
}

+ (void)setAnimationsEnabled:(BOOL)enabled
{
	_animationsEnabled = enabled;
}

@end
