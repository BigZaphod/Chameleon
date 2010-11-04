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
			return [[[UIRoundedRectButton alloc] init] autorelease];
			
		case UIButtonTypeCustom:
		default:
			return [[[self alloc] init] autorelease];
	}
}

- (id)initWithFrame:(CGRect)frame
{
	if ((self=[super initWithFrame:frame])) {
		_buttonType = UIButtonTypeCustom;
		_content = [[NSMutableDictionary alloc] init];
		_titleLabel = [[UILabel alloc] init];
		_imageView = [[UIImageView alloc] init];
		_backgroundImageView = [[UIImageView alloc] init];
		_adjustsImageWhenHighlighted = YES;
		_adjustsImageWhenDisabled = YES;
		_showsTouchWhenHighlighted = NO;

		self.opaque = NO;
		_titleLabel.backgroundColor = [UIColor clearColor];
		_titleLabel.textAlignment = UITextAlignmentLeft;
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
	
	UIImage *image = [self _contentForState:state type:UIButtonContentTypeImage];
	UIImage *backgroundImage = [self _contentForState:state type:UIButtonContentTypeBackgroundImage];
	
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

	if (!backgroundImage) {
		backgroundImage = [self backgroundImageForState:state];
		if (_adjustsImageWhenDisabled && state & UIControlStateDisabled) {
			[_backgroundImageView _setDrawMode:_UIImageViewDrawModeDisabled];
		} else if (_adjustsImageWhenHighlighted && state & UIControlStateHighlighted) {
			[_backgroundImageView _setDrawMode:_UIImageViewDrawModeHighlighted];
		} else {
			[_backgroundImageView _setDrawMode:_UIImageViewDrawModeNormal];
		}
	} else {
		[_backgroundImageView _setDrawMode:_UIImageViewDrawModeNormal];
	}
	
	_imageView.image = image;
	_backgroundImageView.image = backgroundImage;
}

- (void)_setContent:(id)value forState:(UIControlState)state type:(NSString *)type
{
	NSMutableDictionary *typeContent = [_content objectForKey:type];
	
	if (!typeContent) {
		typeContent = [[[NSMutableDictionary alloc] init] autorelease];
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
	return UIEdgeInsetsInsetRect(bounds,_contentEdgeInsets);
}

- (CGSize)_titleSizeForState:(UIControlState)state
{
	NSString *title = [self titleForState:state];
	return ([title length] > 0)? [title sizeWithFont:_titleLabel.font constrainedToSize:CGSizeMake(CGFLOAT_MAX,CGFLOAT_MAX)] : CGSizeZero;
}

- (CGSize)_imageSizeForState:(UIControlState)state
{
	UIImage *image = [self imageForState:state];
	return image ? image.size : CGSizeZero;
}

- (CGSize)_contentSizeForState:(UIControlState)state
{
	const CGSize imageSize = [self _imageSizeForState:state];
	const CGSize titleSize = [self _titleSizeForState:state];
	return CGSizeMake(titleSize.width+imageSize.width, MAX(titleSize.height,imageSize.height));
}

- (CGRect)_alignComponentRect:(CGRect)rect forContentRect:(CGRect)contentRect state:(UIControlState)state
{
	const CGSize contentSize = [self _contentSizeForState:state];
	
	rect.origin.x += contentRect.origin.x;
	rect.origin.y += contentRect.origin.y;
	
	switch (self.contentHorizontalAlignment) {
		case UIControlContentHorizontalAlignmentCenter:
			rect.origin.x += roundf((contentRect.size.width/2.f) - (contentSize.width/2.f));
			break;
			
		case UIControlContentHorizontalAlignmentRight:
			rect.origin.x += contentRect.size.width - contentSize.width;
			break;
			
		case UIControlContentHorizontalAlignmentFill:
			rect.size.width = contentRect.size.width;
			break;
	}
	
	switch (self.contentVerticalAlignment) {
		case UIControlContentVerticalAlignmentCenter:
			rect.origin.y += roundf((contentRect.size.height/2.f) - (rect.size.height/2.f));
			break;
			
		case UIControlContentVerticalAlignmentBottom:
			rect.origin.y += contentRect.size.height - rect.size.height;
			break;

		case UIControlContentVerticalAlignmentFill:
			rect.size.height = contentRect.size.height;
			break;
	}
	
	return rect;
}

- (CGRect)titleRectForContentRect:(CGRect)contentRect
{
	const UIControlState state = self.state;

	CGRect titleRect = CGRectZero;
	titleRect.origin.x += [self _imageSizeForState:state].width;
	titleRect.size = [self _titleSizeForState:state];

	return [self _alignComponentRect:titleRect forContentRect:UIEdgeInsetsInsetRect(contentRect,_titleEdgeInsets) state:state];
}

- (CGRect)imageRectForContentRect:(CGRect)contentRect
{
	const UIControlState state = self.state;

	CGRect imageRect = CGRectZero;
	imageRect.size = [self _imageSizeForState:state];
	
	return [self _alignComponentRect:imageRect forContentRect:UIEdgeInsetsInsetRect(contentRect,_imageEdgeInsets) state:state];
}

- (void)layoutSubviews
{
	[super layoutSubviews];

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
	[super _stateDidChange];
	[self _updateContent];
}

- (CGSize)sizeThatFits:(CGSize)size
{
	const UIControlState state = self.state;
	
	CGSize fitSize = [self _contentSizeForState:state];
	
	UIImage *backgroundImage = [self backgroundImageForState:state];
	if (backgroundImage) {
		fitSize.width = MAX(fitSize.width, backgroundImage.size.width);
		fitSize.height = MAX(fitSize.height, backgroundImage.size.height);
	}

	fitSize.width += _contentEdgeInsets.left + _contentEdgeInsets.right;
	fitSize.height += _contentEdgeInsets.top + _contentEdgeInsets.bottom;

	return fitSize;
}

@end
