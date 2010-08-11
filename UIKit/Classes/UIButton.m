//  Created by Sean Heber on 6/24/10.
#import "UIButton.h"
#import "UIControl+UIPrivate.h"
#import "UILabel.h"
#import "UIImage.h"
#import "UIImageView+UIPrivate.h"
#import "UIRoundedRectButton.h"
#import "UIColor.h"

static NSString *UIButtonContentTypeTitle = @"UIButtonContentTypeTitle";
static NSString *UIButtonContentTypeTitleColor = @"UIButtonContentTypeTitleColor";
static NSString *UIButtonContentTypeTitleShadowColor = @"UIButtonContentTypeTitleShadowColor";
static NSString *UIButtonContentTypeBackgroundImage = @"UIButtonContentTypeBackgroundImage";
static NSString *UIButtonContentTypeImage = @"UIButtonContentTypeImage";

@implementation UIButton
@synthesize buttonType=_buttonType, titleLabel=_titleLabel, reversesTitleShadowWhenHighlighted=_reversesTitleShadowWhenHighlighted;
@synthesize adjustsImageWhenHighlighted=_adjustsImageWhenHighlighted, adjustsImageWhenDisabled=_adjustsImageWhenDisabled;
@synthesize showsTouchWhenHighlighted=_showsTouchWhenHighlighted, imageView=_imageView, contentEdgeInsets=_contentEdgeInsets;
@synthesize titleEdgeInsets=_titleEdgeInsets, imageEdgeInsets=_imageEdgeInsets;

+ (id)buttonWithType:(UIButtonType)buttonType
{
	switch (buttonType) {
		case UIButtonTypeRoundedRect:
		case UIButtonTypeDetailDisclosure:
		case UIButtonTypeInfoLight:
		case UIButtonTypeInfoDark:
		case UIButtonTypeContactAdd:
			return [[UIRoundedRectButton new] autorelease];
			
		case UIButtonTypeCustom:
		default:
			return [[self new] autorelease];
	}
}

- (id)initWithFrame:(CGRect)frame
{
	if ((self=[super initWithFrame:frame])) {
		_buttonType = UIButtonTypeCustom;
		_content = [NSMutableDictionary new];
		_titleLabel = [UILabel new];
		_imageView = [UIImageView new];
		_backgroundImageView = [UIImageView new];
		_adjustsImageWhenHighlighted = YES;
		_adjustsImageWhenDisabled = YES;
		_showsTouchWhenHighlighted = NO;

		self.opaque = NO;
		_titleLabel.backgroundColor = [UIColor clearColor];
		_titleLabel.textAlignment = UITextAlignmentCenter;
		_titleLabel.shadowOffset = CGSizeZero;
		[self addSubview:_backgroundImageView];
		[self addSubview:_imageView];
		[self addSubview:_titleLabel];
	}
	return self;
}
					 
- (void)dealloc
{
	[_content release];
	[_titleLabel release];
	[_imageView release];
	[_backgroundImageView release];
	[_adjustedHighlightImage release];
	[_adjustedDisabledImage release];
	[super dealloc];
}

- (NSString *)currentTitle
{
	return _titleLabel.text;
}

- (UIColor *)currentTitleColor
{
	return _titleLabel.textColor;
}

- (UIColor *)currentTitleShadowColor
{
	return _titleLabel.shadowColor;
}

- (UIImage *)currentImage
{
	return _imageView.image;
}

- (UIImage *)currentBackgroundImage
{
	return _backgroundImageView.image;
}

- (UIColor *)_defaultTitleColor
{
	return [UIColor whiteColor];
}

- (UIColor *)_defaultTitleShadowColor
{
	return [UIColor whiteColor];
}

- (id)_contentForState:(UIControlState)state type:(NSString *)type
{
	return [[_content objectForKey:type] objectForKey:[NSNumber numberWithInt:state]];
}

- (id)_normalContentForState:(UIControlState)state type:(NSString *)type
{
	return [self _contentForState:state type:type] ?: [self _contentForState:UIControlStateNormal type:type];
}

- (void)_updateContent
{
	const UIControlState state = self.state;
	_titleLabel.text = [self titleForState:state];
	_titleLabel.textColor = [self titleColorForState:state] ?: [self _defaultTitleColor];
	_titleLabel.shadowColor = [self titleShadowColorForState:state] ?: [self _defaultTitleShadowColor];
	_backgroundImageView.image = [self backgroundImageForState:state];
	
	// Setting the image is a bit trickier because we may need to adjust it...
	UIImage *image = [self _contentForState:state type:UIButtonContentTypeImage];
	if (!image) {
		image = [self imageForState:state];	// find the correct default image to show
		if (_adjustsImageWhenDisabled && state & UIControlStateDisabled) {
			[_imageView _setDrawMode:_UIImageViewDrawModeDisabled];
		} else if (_adjustsImageWhenHighlighted && state & UIControlStateHighlighted) {
			[_imageView _setDrawMode:_UIImageViewDrawModeHighlighted];
		} else {
			[_imageView _setDrawMode:_UIImageViewDrawModeNormal];
		}
	} else {
		[_imageView _setDrawMode:_UIImageViewDrawModeNormal];
	}
	_imageView.image = image;
}

- (void)_setContent:(id)value forState:(UIControlState)state type:(NSString *)type
{
	NSMutableDictionary *typeContent = [_content objectForKey:type];
	
	if (!typeContent) {
		typeContent = [[NSMutableDictionary new] autorelease];
		[_content setObject:typeContent forKey:type];
	}
	
	NSNumber *key = [NSNumber numberWithInt:state];
	if (value) {
		[typeContent setObject:value forKey:key];
	} else {
		[typeContent removeObjectForKey:key];
	}
	
	[self _updateContent];
}

- (void)setTitle:(NSString *)title forState:(UIControlState)state
{
	[self _setContent:title forState:state type:UIButtonContentTypeTitle];
}

- (void)setTitleColor:(UIColor *)color forState:(UIControlState)state
{
	[self _setContent:color forState:state type:UIButtonContentTypeTitleColor];
}

- (void)setTitleShadowColor:(UIColor *)color forState:(UIControlState)state
{
	[self _setContent:color forState:state type:UIButtonContentTypeTitleShadowColor];
}

- (void)setBackgroundImage:(UIImage *)image forState:(UIControlState)state
{
	[self _setContent:image forState:state type:UIButtonContentTypeBackgroundImage];
}

- (void)setImage:(UIImage *)image forState:(UIControlState)state
{
	[_adjustedHighlightImage release];
	[_adjustedDisabledImage release];
	_adjustedDisabledImage = _adjustedHighlightImage = nil;
	[self _setContent:image forState:state type:UIButtonContentTypeImage];
}

- (NSString *)titleForState:(UIControlState)state
{
	return [self _normalContentForState:state type:UIButtonContentTypeTitle];
}

- (UIColor *)titleColorForState:(UIControlState)state
{
	return [self _normalContentForState:state type:UIButtonContentTypeTitleColor];
}

- (UIColor *)titleShadowColorForState:(UIControlState)state
{
	return [self _normalContentForState:state type:UIButtonContentTypeTitleShadowColor];
}

- (UIImage *)backgroundImageForState:(UIControlState)state
{
	return [self _normalContentForState:state type:UIButtonContentTypeBackgroundImage];
}

- (UIImage *)imageForState:(UIControlState)state
{
	return [self _normalContentForState:state type:UIButtonContentTypeImage];
}

- (CGRect)backgroundRectForBounds:(CGRect)bounds
{
	return bounds;
}

- (CGRect)contentRectForBounds:(CGRect)bounds
{
	return bounds;
}

- (CGRect)titleRectForContentRect:(CGRect)contentRect
{
	return UIEdgeInsetsInsetRect(contentRect,_titleEdgeInsets);
}

- (CGRect)imageRectForContentRect:(CGRect)contentRect
{
	CGRect imageRect;

	// I think the origin would change based on contentHorizontalAlignment, and contentVerticalAlignment properties
	imageRect.origin = contentRect.origin;
	imageRect.size = [self imageForState:UIControlStateNormal].size;
	
	return imageRect;
}

- (void)layoutSubviews
{
	CGRect bounds = self.bounds;
	CGRect backgroundRect = [self backgroundRectForBounds:bounds];
	CGRect contentRect = [self contentRectForBounds:bounds];
	CGRect titleRect = [self titleRectForContentRect:contentRect];
	_backgroundImageView.frame = backgroundRect;
	_titleLabel.frame = titleRect;
	_imageView.frame = [self imageRectForContentRect:contentRect];
}

- (void)_stateDidChange
{
	[self _updateContent];
	[super _stateDidChange];
}

- (CGSize)sizeThatFits:(CGSize)size
{
	// this needs to take into account the various insets and stuff, I suspect.. and maybe the image?
	// will have to do a fair bit of reverse engineering to see how the real UIKit does this, if it is needed.
	CGSize fitSize = [[self titleForState:UIControlStateNormal] sizeWithFont:_titleLabel.font constrainedToSize:CGSizeMake(CGFLOAT_MAX,CGFLOAT_MAX)];
	
	fitSize.width += _titleEdgeInsets.left + _titleEdgeInsets.right;
	fitSize.height += _titleEdgeInsets.top + _titleEdgeInsets.bottom;
	
	fitSize.width = MAX(fitSize.width, [self imageForState:UIControlStateNormal].size.width);
	fitSize.height = MAX(fitSize.height, [self imageForState:UIControlStateNormal].size.height);
	
	fitSize.width = MAX(fitSize.width, [self backgroundImageForState:UIControlStateNormal].size.width);
	fitSize.height = MAX(fitSize.height, [self backgroundImageForState:UIControlStateNormal].size.height);
	
	return fitSize;
}

@end
