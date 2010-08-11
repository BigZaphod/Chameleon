//  Created by Sean Heber on 6/24/10.
#import "UIControl.h"

typedef enum {
	UIButtonTypeCustom = 0,
	UIButtonTypeRoundedRect,
	UIButtonTypeDetailDisclosure,
	UIButtonTypeInfoLight,
	UIButtonTypeInfoDark,
	UIButtonTypeContactAdd,
} UIButtonType;

@class UILabel, UIImageView, UIImage;

@interface UIButton : UIControl {
@protected
	UIButtonType _buttonType;
@private
	UILabel *_titleLabel;
	UIImageView *_imageView;
	UIImageView *_backgroundImageView;
	BOOL _reversesTitleShadowWhenHighlighted;
	BOOL _adjustsImageWhenHighlighted;
	BOOL _adjustsImageWhenDisabled;
	BOOL _showsTouchWhenHighlighted;
	UIEdgeInsets _contentEdgeInsets;
	UIEdgeInsets _titleEdgeInsets;
	UIEdgeInsets _imageEdgeInsets;
	NSMutableDictionary *_content;
	UIImage *_adjustedHighlightImage;
	UIImage *_adjustedDisabledImage;
}

+ (id)buttonWithType:(UIButtonType)buttonType;

- (void)setTitle:(NSString *)title forState:(UIControlState)state;
- (void)setTitleColor:(UIColor *)color forState:(UIControlState)state;
- (void)setTitleShadowColor:(UIColor *)color forState:(UIControlState)state;
- (void)setBackgroundImage:(UIImage *)image forState:(UIControlState)state;
- (void)setImage:(UIImage *)image forState:(UIControlState)state;

- (NSString *)titleForState:(UIControlState)state;
- (UIColor *)titleColorForState:(UIControlState)state;
- (UIColor *)titleShadowColorForState:(UIControlState)state;
- (UIImage *)backgroundImageForState:(UIControlState)state;
- (UIImage *)imageForState:(UIControlState)state;

- (CGRect)backgroundRectForBounds:(CGRect)bounds;
- (CGRect)contentRectForBounds:(CGRect)bounds;
- (CGRect)titleRectForContentRect:(CGRect)contentRect;
- (CGRect)imageRectForContentRect:(CGRect)contentRect;

@property (nonatomic, readonly) UIButtonType buttonType;
@property (nonatomic,readonly,retain) UILabel *titleLabel;
@property (nonatomic,readonly,retain) UIImageView *imageView;
@property (nonatomic) BOOL reversesTitleShadowWhenHighlighted;
@property (nonatomic) BOOL adjustsImageWhenHighlighted;
@property (nonatomic) BOOL adjustsImageWhenDisabled;
@property (nonatomic) BOOL showsTouchWhenHighlighted;		// no effect
@property (nonatomic) UIEdgeInsets contentEdgeInsets;
@property (nonatomic) UIEdgeInsets titleEdgeInsets;
@property (nonatomic) UIEdgeInsets imageEdgeInsets;

@property (nonatomic, readonly, retain) NSString *currentTitle;
@property (nonatomic, readonly, retain) UIColor *currentTitleColor;
@property (nonatomic, readonly, retain) UIColor *currentTitleShadowColor;
@property (nonatomic, readonly, retain) UIImage *currentImage;
@property (nonatomic, readonly, retain) UIImage *currentBackgroundImage;


@end
