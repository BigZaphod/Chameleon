/*
 * Copyright (c) 2011, The Iconfactory. All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 *
 * 2. Redistributions in binary form must reproduce the above copyright notice,
 *    this list of conditions and the following disclaimer in the documentation
 *    and/or other materials provided with the distribution.
 *
 * 3. Neither the name of The Iconfactory nor the names of its contributors may
 *    be used to endorse or promote products derived from this software without
 *    specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE ICONFACTORY BE LIABLE FOR ANY DIRECT,
 * INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
 * BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
 * LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
 * OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
 * ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import "UIButton.h"
#import "UIButton+UIPrivate.h"
#import "UIButtonContent.h"
#import "UIControl+UIPrivate.h"
#import "UILabel.h"
#import "UIImage.h"
#import "UIImageView+UIPrivate.h"
#import "UIRoundedRectButton.h"
#import "UIColor.h"
#import <AppKit/AppKit.h>

static NSString* const kUIAdjustsImageWhenDisabledKey = @"UIAdjustsImageWhenDisabled";
static NSString* const kUIAdjustsImageWhenHighlightedKey = @"UIAdjustsImageWhenHighlighted";
static NSString* const kUIButtonStatefulContentKey = @"UIButtonStatefulContent";
static NSString* const kUIButtonTypeKey = @"UIButtonType";
static NSString* const kUIFontKey = @"UIFont";

@implementation UIButton {
    UIImageView *_backgroundImageView;
    NSMutableDictionary *_content;
    UIImage *_adjustedHighlightImage;
    UIImage *_adjustedDisabledImage;
	CGSize originalShadowOffset;
    struct {
        UIButtonType buttonType : 8;
    } _buttonFlags;
}
@synthesize titleLabel = _titleLabel;
@synthesize reversesTitleShadowWhenHighlighted = _reversesTitleShadowWhenHighlighted;
@synthesize adjustsImageWhenHighlighted = _adjustsImageWhenHighlighted;
@synthesize adjustsImageWhenDisabled = _adjustsImageWhenDisabled;
@synthesize showsTouchWhenHighlighted = _showsTouchWhenHighlighted;
@synthesize imageView = _imageView;
@synthesize contentEdgeInsets = _contentEdgeInsets;
@synthesize titleEdgeInsets = _titleEdgeInsets;
@synthesize imageEdgeInsets = _imageEdgeInsets;

static UIImage* detailDisclosureButtonImage;
static UIImage* detailDisclosureButtonImagePressed;

static NSNumber* kUIControlStateNormalKey;
static NSNumber* kUIControlStateHighlightedKey;
static NSNumber* kUIControlStateDisabledKey;
static NSNumber* kUIControlStateSelectedKey;

inline static NSNumber* _keyForState(NSInteger state) 
{
    switch (state) {
        case UIControlStateNormal:      return kUIControlStateNormalKey;
        case UIControlStateHighlighted: return kUIControlStateHighlightedKey;
        case UIControlStateDisabled:    return kUIControlStateDisabledKey;
        case UIControlStateSelected:    return kUIControlStateSelectedKey;
    }
    return nil;
}

+ (void) initialize
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSBundle* bundle = [NSBundle bundleForClass:[self class]];
        detailDisclosureButtonImage = [[UIImage imageWithContentsOfFile:[bundle pathForImageResource:@"<UIButton> detailDisclosureButton"]] retain];
        detailDisclosureButtonImagePressed = [[UIImage imageWithContentsOfFile:[bundle pathForImageResource:@"<UIButton> detailDisclosureButtonPressed"]] retain];

        kUIControlStateNormalKey = [[NSNumber alloc] initWithInteger:UIControlStateNormal];
        kUIControlStateHighlightedKey = [[NSNumber alloc] initWithInteger:UIControlStateHighlighted];
        kUIControlStateDisabledKey = [[NSNumber alloc] initWithInteger:UIControlStateDisabled];
        kUIControlStateSelectedKey = [[NSNumber alloc] initWithInteger:UIControlStateSelected];
    });
}

+ (UIButtonContent*) _defaultContentForType:(UIButtonType)buttonType andState:(UIControlState)state
{
    return nil;
}

+ (id)buttonWithType:(UIButtonType)buttonType
{
    switch (buttonType) {
        case UIButtonTypeDetailDisclosure: {
            CGRect frame = {
                .size = detailDisclosureButtonImage.size
            };
            UIButton* button = [[UIButton alloc] initWithFrame:frame];
            [button setImage:detailDisclosureButtonImage forState:UIControlStateNormal];
            [button setImage:detailDisclosureButtonImagePressed forState:UIControlStateHighlighted];
            return [button autorelease];
        }

        case UIButtonTypeRoundedRect:
        case UIButtonTypeInfoLight:
        case UIButtonTypeInfoDark:
        case UIButtonTypeContactAdd:
            return [[[UIRoundedRectButton alloc] init] autorelease];
            
        case UIButtonTypeCustom:
        default: {
            return [[[UIButton alloc] init] autorelease];
        }
    }
}

- (void) _commonInitForUIButton
{
    _buttonFlags.buttonType = UIButtonTypeCustom;
    _content = [[NSMutableDictionary alloc] init];
    _titleLabel = [[UILabel alloc] init];
    _imageView = [[UIImageView alloc] init];
    _backgroundImageView = [[UIImageView alloc] init];
    _adjustsImageWhenHighlighted = YES;
    _adjustsImageWhenDisabled = YES;
    _showsTouchWhenHighlighted = NO;
    
    self.opaque = NO;
    _titleLabel.lineBreakMode = UILineBreakModeMiddleTruncation;
    _titleLabel.backgroundColor = [UIColor clearColor];
    _titleLabel.textAlignment = UITextAlignmentLeft;
    _titleLabel.shadowOffset = CGSizeZero;
    [self addSubview:_backgroundImageView];
    [self addSubview:_imageView];
    [self addSubview:_titleLabel];
}

- (id) initWithFrame:(CGRect)frame
{
    if (nil != (self = [super initWithFrame:frame])) {
        [self _commonInitForUIButton];
    }
    return self;
}

- (id) initWithCoder:(NSCoder*)coder
{
    if (nil != (self = [super initWithCoder:coder])) {
        [self _commonInitForUIButton];
        if ([coder containsValueForKey:kUIAdjustsImageWhenDisabledKey]) {
            self.adjustsImageWhenDisabled = [coder decodeBoolForKey:kUIAdjustsImageWhenDisabledKey];
        }
        if ([coder containsValueForKey:kUIAdjustsImageWhenHighlightedKey]) {
            self.adjustsImageWhenHighlighted = [coder decodeBoolForKey:kUIAdjustsImageWhenHighlightedKey];
        }
        if ([coder containsValueForKey:kUIButtonStatefulContentKey]) {
            [_content release], _content = [[coder decodeObjectForKey:kUIButtonStatefulContentKey] retain];
        }
        if ([coder containsValueForKey:kUIButtonTypeKey]) {
            _buttonFlags.buttonType = [coder decodeIntegerForKey:kUIButtonTypeKey];
        }
        if ([coder containsValueForKey:kUIFontKey]) {
            self.titleLabel.font = [coder decodeObjectForKey:kUIFontKey];
        }
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

- (UIButtonType) buttonType
{
    return _buttonFlags.buttonType;
}

- (void) _setButtonType:(UIButtonType)buttonType
{
    _buttonFlags.buttonType = buttonType;
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

- (void)_updateContent
{
    const UIControlState state = self.state;
    _titleLabel.text = [self titleForState:state];
    _titleLabel.textColor = [self titleColorForState:state] ?: [self _defaultTitleColor];
    _titleLabel.shadowColor = [self titleShadowColorForState:state] ?: [self _defaultTitleShadowColor];
	
	if(self.reversesTitleShadowWhenHighlighted) {
		if(!self.highlighted && CGSizeEqualToSize(originalShadowOffset, CGSizeZero)) {
			originalShadowOffset = self.titleLabel.shadowOffset;
		}
		
		self.titleLabel.shadowOffset = CGSizeMake(self.titleLabel.shadowOffset.width, self.highlighted ? -originalShadowOffset.height : originalShadowOffset.height);
	}
    
    UIImage *image = [[_content objectForKey:_keyForState(state)] image];
    UIImage *backgroundImage = [[_content objectForKey:_keyForState(state)] backgroundImage];
    
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
    
    [self setNeedsLayout];
}

- (void)setTitle:(NSString *)title forState:(UIControlState)state
{
    id key = _keyForState(state);
    UIButtonContent* content = [_content objectForKey:key];
    if (!content) {
        content = [[UIButtonContent alloc] init];
        [_content setValue:content forKey:key];
        [content release];
    }
    content.title = title;
    [self _updateContent];
}

- (void)setTitleColor:(UIColor *)titleColor forState:(UIControlState)state
{
    id key = _keyForState(state);
    UIButtonContent* content = [_content objectForKey:key];
    if (!content) {
        content = [[UIButtonContent alloc] init];
        [_content setValue:content forKey:key];
        [content release];
    }
    content.titleColor = titleColor;
    [self _updateContent];
}

- (void)setTitleShadowColor:(UIColor *)shadowColor forState:(UIControlState)state
{
    id key = _keyForState(state);
    UIButtonContent* content = [_content objectForKey:key];
    if (!content) {
        content = [[UIButtonContent alloc] init];
        [_content setValue:content forKey:key];
        [content release];
    }
    content.shadowColor = shadowColor;
    [self _updateContent];
}

- (void)setBackgroundImage:(UIImage *)backgroundImage forState:(UIControlState)state
{
    id key = _keyForState(state);
    UIButtonContent* content = [_content objectForKey:key];
    if (!content) {
        content = [[UIButtonContent alloc] init];
        [_content setValue:content forKey:key];
        [content release];
    }
    content.backgroundImage = backgroundImage;
    [self _updateContent];
}

- (void)setImage:(UIImage *)image forState:(UIControlState)state
{
    [_adjustedHighlightImage release];
    [_adjustedDisabledImage release];
    _adjustedDisabledImage = _adjustedHighlightImage = nil;
    id key = _keyForState(state);
    UIButtonContent* content = [_content objectForKey:key];
    if (!content) {
        content = [[UIButtonContent alloc] init];
        [_content setValue:content forKey:key];
        [content release];
    }
    content.image = image;
    if (state == UIControlStateNormal) {
        [_imageView setImage:image];
    } else if (state == UIControlStateHighlighted) {
        [_imageView setHighlightedImage:image];
    }
    [self _updateContent];
}

- (NSString *)titleForState:(UIControlState)state
{
    return [[_content objectForKey:_keyForState(state)] title] ?: [[_content objectForKey:kUIControlStateNormalKey] title] ?: [[UIButton _defaultContentForType:_buttonFlags.buttonType andState:state] title];
}

- (UIColor *)titleColorForState:(UIControlState)state
{
    return [[_content objectForKey:_keyForState(state)] titleColor] ?: [[_content objectForKey:kUIControlStateNormalKey] titleColor] ?: [[UIButton _defaultContentForType:_buttonFlags.buttonType andState:state] titleColor];
}

- (UIColor *)titleShadowColorForState:(UIControlState)state
{
    return [[_content objectForKey:_keyForState(state)] shadowColor] ?: [[_content objectForKey:kUIControlStateNormalKey] shadowColor] ?: [[UIButton _defaultContentForType:_buttonFlags.buttonType andState:state] shadowColor];
}

- (UIImage *)backgroundImageForState:(UIControlState)state
{
    return [[_content objectForKey:_keyForState(state)] backgroundImage] ?: [[_content objectForKey:kUIControlStateNormalKey] backgroundImage] ?: [[UIButton _defaultContentForType:_buttonFlags.buttonType andState:state] backgroundImage];
}

- (UIImage *)imageForState:(UIControlState)state
{
    return [[_content objectForKey:_keyForState(state)] image] ?: [[_content objectForKey:kUIControlStateNormalKey] image] ?: [[UIButton _defaultContentForType:_buttonFlags.buttonType andState:state] image];
}

- (CGRect)backgroundRectForBounds:(CGRect)bounds
{
    return bounds;
}

- (CGRect)contentRectForBounds:(CGRect)bounds
{
    return UIEdgeInsetsInsetRect(bounds,_contentEdgeInsets);
}

- (CGSize)_backgroundSizeForState:(UIControlState)state
{
    UIImage *backgroundImage = [self backgroundImageForState:state];
    return backgroundImage? backgroundImage.size : CGSizeZero;
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

- (CGRect)_componentRectForSize:(CGSize)size inContentRect:(CGRect)contentRect withState:(UIControlState)state
{
    CGRect rect;

    rect.origin = contentRect.origin;
    rect.size = size;
    
    // clamp the right edge of the rect to the contentRect - this is what the real UIButton appears to do.
    if (CGRectGetMaxX(rect) > CGRectGetMaxX(contentRect)) {
        rect.size.width -= CGRectGetMaxX(rect) - CGRectGetMaxX(contentRect);
    }
    
    switch (self.contentHorizontalAlignment) {
        case UIControlContentHorizontalAlignmentCenter:
            rect.origin.x += floorf((contentRect.size.width/2.f) - (rect.size.width/2.f));
            break;
            
        case UIControlContentHorizontalAlignmentRight:
            rect.origin.x += contentRect.size.width - rect.size.width;
            break;
            
        case UIControlContentHorizontalAlignmentFill:
            rect.size.width = contentRect.size.width;
            break;
            
        case UIControlContentHorizontalAlignmentLeft:
            // don't do anything - it's already left aligned
            break;
    }
    
    switch (self.contentVerticalAlignment) {
        case UIControlContentVerticalAlignmentCenter:
            rect.origin.y += floorf((contentRect.size.height/2.f) - (rect.size.height/2.f));
            break;
            
        case UIControlContentVerticalAlignmentBottom:
            rect.origin.y += contentRect.size.height - rect.size.height;
            break;
            
        case UIControlContentVerticalAlignmentFill:
            rect.size.height = contentRect.size.height;
            break;
            
        case UIControlContentVerticalAlignmentTop:
            // don't do anything - it's already top aligned
            break;
    }
    
    return rect;
}

- (CGRect)titleRectForContentRect:(CGRect)contentRect
{
    const UIControlState state = self.state;
    
    UIEdgeInsets inset = _titleEdgeInsets;
    inset.left += [self _imageSizeForState:state].width;
    
    return [self _componentRectForSize:[self _titleSizeForState:state] inContentRect:UIEdgeInsetsInsetRect(contentRect,inset) withState:state];
}

- (CGRect)imageRectForContentRect:(CGRect)contentRect
{
    const UIControlState state = self.state;
    
    UIEdgeInsets inset = _imageEdgeInsets;
    inset.right += [self titleRectForContentRect:contentRect].size.width;
    
    return [self _componentRectForSize:[self _imageSizeForState:state] inContentRect:UIEdgeInsetsInsetRect(contentRect,inset) withState:state];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    const CGRect bounds = self.bounds;
    const CGRect contentRect = [self contentRectForBounds:bounds];

    _backgroundImageView.frame = [self backgroundRectForBounds:bounds];
    _titleLabel.frame = [self titleRectForContentRect:contentRect];
    _imageView.frame = [self imageRectForContentRect:contentRect];
}

- (void)_stateWillChange {
	[super _stateWillChange];
	
	if(!self.highlighted) {
		originalShadowOffset = self.titleLabel.shadowOffset;
	}
}

- (void)_stateDidChange
{
    [super _stateDidChange];
    [self _updateContent];
}

- (CGSize)sizeThatFits:(CGSize)size
{
    const UIControlState state = self.state;
    
    const CGSize imageSize = [self _imageSizeForState:state];
    const CGSize titleSize = [self _titleSizeForState:state];
    
    CGSize fitSize;
    fitSize.width = _contentEdgeInsets.left + _contentEdgeInsets.right + titleSize.width + imageSize.width;
    fitSize.height = _contentEdgeInsets.top + _contentEdgeInsets.bottom + MAX(titleSize.height,imageSize.height);
    
    UIImage* background = [self currentBackgroundImage];
    if(background) {
        CGSize backgroundSize = background.size;
        fitSize.width = MAX(fitSize.width, backgroundSize.width);
        fitSize.height = MAX(fitSize.height, backgroundSize.height);
    }
    
    return fitSize;
}

- (void)rightClick:(UITouch *)touch withEvent:(UIEvent *)event
{
    // I'm swallowing right clicks on buttons by default, which is why this is here.
    // This isn't a strong decision, but there's a few places in Twitterrific where passing a right click through a button doesn't feel right.
    // It also doesn't feel immediately right to treat a right-click on a button as a normal click event, either, so this seems to be a
    // decent way to avoid the problem in general and define a kind of "standard" behavior in this case.
}

@end
