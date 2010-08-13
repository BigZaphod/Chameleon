//  Created by Sean Heber on 6/17/10.
#import "UIView.h"
#import "UIStringDrawing.h"

@class UIFont, UIColor;

@interface UILabel : UIView {
@private
	NSString *_text;
	UIFont *_font;
	UIColor *_textColor;
	UIColor *_highlightedTextColor;
	UIColor *_shadowColor;
	CGSize _shadowOffset;
	UITextAlignment _textAlignment;
	UILineBreakMode _lineBreakMode;
	BOOL _enabled;
	NSInteger _numberOfLines;
	UIBaselineAdjustment _baselineAdjustment;
	BOOL _adjustsFontSizeToFitWidth;
	CGFloat _minimumFontSize;
	BOOL _highlighted;
}

@property (nonatomic, copy) NSString *text;
@property (nonatomic, retain) UIFont *font;
@property (nonatomic, retain) UIColor *textColor;
@property (nonatomic, retain) UIColor *highlightedTextColor;
@property (nonatomic, retain) UIColor *shadowColor;
@property (nonatomic) CGSize shadowOffset;
@property (nonatomic) UITextAlignment textAlignment;
@property (nonatomic) UILineBreakMode lineBreakMode;
@property (nonatomic, getter=isEnabled) BOOL enabled;
@property (nonatomic) NSInteger numberOfLines;					// currently only supports 0 or 1
@property (nonatomic) UIBaselineAdjustment baselineAdjustment;	// not implemented
@property (nonatomic) BOOL adjustsFontSizeToFitWidth;			// not implemented
@property (nonatomic) CGFloat minimumFontSize;					// not implemented
@property (nonatomic, getter=isHighlighted) BOOL highlighted;


- (CGRect)textRectForBounds:(CGRect)bounds limitedToNumberOfLines:(NSInteger)numberOfLines;
- (void)drawTextInRect:(CGRect)rect;

@end
