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
 *
 *
 * Much of this code for attributed text is taken from TTTAttributedLabel
 *
 * TTTAttributedLabel.m
 *
 * Copyright (c) 2011 Mattt Thompson (http://mattt.me)
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */


#import "UILabel.h"
#import "UIColor.h"
#import "UIFont.h"
#import "UIGraphics.h"
#import "UIFontAppKitIntegration.h"
#import "UIColorAppKitIntegration.h"
#import "NSAttributedString+UIPrivate.h"
#import <AppKit/NSColor.h>
#import <AppKit/NSApplication.h>
#import <AppKit/NSAttributedString.h>
#import <AppKit/NSParagraphStyle.h>

#define kUILabelLineBreakWordWrapTextWidthScalingFactor (M_PI / M_E)

static CGFloat const UILABEL_FLOAT_MAX = 100000;

static inline CGFloat UILabelFlushFactorForTextAlignment(UITextAlignment textAlignment) {
    switch (textAlignment) {
        case UITextAlignmentCenter:
            return 0.5f;
        case UITextAlignmentRight:
            return 1.0f;
        case UITextAlignmentLeft:
        default:
            return 0.0f;
    }
}

static inline CTTextAlignment CTTextAlignmentFromUITextAlignment(UITextAlignment alignment) {
    switch (alignment) {
		case UITextAlignmentLeft: return kCTLeftTextAlignment;
		case UITextAlignmentCenter: return kCTCenterTextAlignment;
		case UITextAlignmentRight: return kCTRightTextAlignment;
        case UITextAlignmentJustified: return kCTJustifiedTextAlignment;
		default: return kCTNaturalTextAlignment;
	}
}

static inline CTLineBreakMode CTLineBreakModeFromUILineBreakMode(UILineBreakMode lineBreakMode) {
    switch (lineBreakMode) {
        case UILineBreakModeWordWrap: return kCTLineBreakByWordWrapping;
        case UILineBreakModeCharacterWrap: return kCTLineBreakByCharWrapping;
        case UILineBreakModeClip: return kCTLineBreakByClipping;
        case UILineBreakModeHeadTruncation: return kCTLineBreakByTruncatingHead;
        case UILineBreakModeTailTruncation: return kCTLineBreakByTruncatingTail;
        case UILineBreakModeMiddleTruncation: return kCTLineBreakByTruncatingMiddle;
        default: return 0;
    }
}

static inline CGFLOAT_TYPE CGFloat_ceil(CGFLOAT_TYPE cgfloat) {
#if CGFLOAT_IS_DOUBLE
    return ceil(cgfloat);
#else
    return ceilf(cgfloat);
#endif
}

static inline CGFLOAT_TYPE CGFloat_floor(CGFLOAT_TYPE cgfloat) {
#if CGFLOAT_IS_DOUBLE
    return floor(cgfloat);
#else
    return floorf(cgfloat);
#endif
}

static inline CGFLOAT_TYPE CGFloat_round(CGFLOAT_TYPE cgfloat) {
#if CGFLOAT_IS_DOUBLE
    return round(cgfloat);
#else
    return roundf(cgfloat);
#endif
}

static inline NSAttributedString * NSAttributedStringByScalingFontSize(NSAttributedString *attributedString, CGFloat scale) {
    NSMutableAttributedString *mutableAttributedString = [attributedString mutableCopy];
    [mutableAttributedString enumerateAttribute:(NSString *)kCTFontAttributeName inRange:NSMakeRange(0, [mutableAttributedString length]) options:0 usingBlock:^(id value, NSRange range, BOOL * __unused stop) {
        UIFont *font = (UIFont *)value;
        if (font) {
            NSString *fontName;
            CGFloat pointSize;
            
            if ([font isKindOfClass:[UIFont class]]) {
                fontName = font.fontName;
                pointSize = font.pointSize;
            } else {
                fontName = (NSString *)CFBridgingRelease(CTFontCopyName((__bridge CTFontRef)font, kCTFontPostScriptNameKey));
                pointSize = CTFontGetSize((__bridge CTFontRef)font);
            }
            
            [mutableAttributedString removeAttribute:(NSString *)kCTFontAttributeName range:range];
            CTFontRef fontRef = CTFontCreateWithName((__bridge CFStringRef)fontName, CGFloat_floor(pointSize * scale), NULL);
            [mutableAttributedString addAttribute:(NSString *)kCTFontAttributeName value:(__bridge id)fontRef range:range];
            CFRelease(fontRef);
        }
    }];
    
    return mutableAttributedString;
}

static inline NSAttributedString * NSAttributedStringBySettingColorFromContext(NSAttributedString *attributedString, UIColor *color) {
    if (!color) {
        return attributedString;
    }
    
    NSMutableAttributedString *mutableAttributedString = [attributedString mutableCopy];
    [mutableAttributedString enumerateAttribute:(NSString *)kCTForegroundColorFromContextAttributeName inRange:NSMakeRange(0, [mutableAttributedString length]) options:0 usingBlock:^(id value, NSRange range, __unused BOOL *stop) {
        BOOL usesColorFromContext = (BOOL)value;
        if (usesColorFromContext) {
            [mutableAttributedString setAttributes:[NSDictionary dictionaryWithObject:color forKey:(NSString *)kCTForegroundColorAttributeName] range:range];
            [mutableAttributedString removeAttribute:(NSString *)kCTForegroundColorFromContextAttributeName range:range];
        }
    }];
    
    return mutableAttributedString;
}

static inline NSDictionary * NSAttributedStringAttributesFromLabel(UILabel *label) {
    NSMutableDictionary *mutableAttributes = [NSMutableDictionary dictionary];
    
    CTFontRef font = CTFontCreateWithName((__bridge CFStringRef)label.font.fontName, label.font.pointSize, NULL);
    [mutableAttributes setObject:(__bridge id)font forKey:(NSString *)kCTFontAttributeName];
    CFRelease(font);
    
    [mutableAttributes setObject:(id)[label.textColor CGColor] forKey:(NSString *)kCTForegroundColorAttributeName];
    
    CTTextAlignment alignment = CTTextAlignmentFromUITextAlignment(label.textAlignment);
    CTLineBreakMode lineBreakMode = kCTLineBreakByWordWrapping;
    if (label.numberOfLines == 1) {
        lineBreakMode = CTLineBreakModeFromUILineBreakMode(label.lineBreakMode);
    }
    
    CTParagraphStyleSetting paragraphStyles[12] = {
        {.spec = kCTParagraphStyleSpecifierAlignment, .valueSize = sizeof(CTTextAlignment), .value = (const void *)&alignment},
        {.spec = kCTParagraphStyleSpecifierLineBreakMode, .valueSize = sizeof(CTLineBreakMode), .value = (const void *)&lineBreakMode},
    };
    
    CTParagraphStyleRef paragraphStyle = CTParagraphStyleCreate(paragraphStyles, 12);
    
    [mutableAttributes setObject:(__bridge id)paragraphStyle forKey:(NSString *)kCTParagraphStyleAttributeName];
    
    CFRelease(paragraphStyle);
    
    return [NSDictionary dictionaryWithDictionary:mutableAttributes];
}

static inline CGSize CTFramesetterSuggestFrameSizeForAttributedStringWithConstraints(CTFramesetterRef framesetter, NSAttributedString *attributedString, CGSize size, NSUInteger numberOfLines) {
    // setup suggested size
    CGSize suggestedSize = CGSizeZero;
    
    // safety checks
    if(!framesetter) {
        return suggestedSize;
    }
    
    CFRetain(framesetter);
    
    // setup constraints
    CGSize constraints = CGSizeMake(UILABEL_FLOAT_MAX, UILABEL_FLOAT_MAX);
    if (numberOfLines > 0) {
        constraints.width = size.width;
    }
    
    // setup range sizing
    CFRange rangeToSize = CFRangeMake(0, 0);
    
    // create frame
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, CGRectMake(0.0f, 0.0f, constraints.width, UILABEL_FLOAT_MAX));
    CTFrameRef frame = CTFramesetterCreateFrame(framesetter, rangeToSize, path, NULL);
    
    // get lines
    CFArrayRef lines = CTFrameGetLines(frame);
    NSInteger linesCount = (lines) ? CFArrayGetCount(lines) : 0;
    
    if(linesCount > 0) {
        CGPoint *linesOrigins = malloc(linesCount * sizeof(CGPoint));
        CTFrameGetLineOrigins(frame, CFRangeMake(0, 0), linesOrigins);
        
        for(NSInteger i = 0; i < linesCount; ++i) {
            CTLineRef line = CFArrayGetValueAtIndex(lines, i);
            
            CGPoint origin = linesOrigins[i];
            CGFloat ascent, descent, leading;
            CGFloat width = CTLineGetTypographicBounds(line, &ascent, &descent, &leading);
            CGFloat trailingWidth = CTLineGetTrailingWhitespaceWidth(line);
            
            CGFloat lineWidth = width - trailingWidth;
            CGFloat lineMaxY = constraints.height - origin.y + descent;
            CFRange lineRange = CTLineGetStringRange(line);
            
            suggestedSize.width = MAX(suggestedSize.width, lineWidth);
            suggestedSize.height = MAX(suggestedSize.height, lineMaxY);
            
            
            rangeToSize.length = lineRange.location + lineRange.length;
            
            if (numberOfLines > 0 && i + 1 == numberOfLines) {
                break;
            }
            
        }
        
        free(linesOrigins);
    }
  
    CGSize coreText = CTFramesetterSuggestFrameSizeWithConstraints(framesetter, rangeToSize, NULL, constraints, NULL);
    coreText.width = MIN(constraints.width, coreText.width);
    coreText.height = MIN(size.height, coreText.height);
    
    suggestedSize = CGSizeMake(suggestedSize.width, CGFloat_round(suggestedSize.height));
    suggestedSize.width = MIN(constraints.width, suggestedSize.width);
    suggestedSize.height = MIN(size.height, suggestedSize.height);
    
    CFRelease(framesetter);
    
    return suggestedSize;
}

@interface UILabel() {
@private
    BOOL _needsFramesetter;
    CTFramesetterRef _framesetter;
    CTFramesetterRef _highlightFramesetter;
}

@property (readwrite, nonatomic, copy) NSAttributedString *attributedTextForDrawing;
@property (readwrite, nonatomic, copy) NSAttributedString *renderedAttributedText;

@end
@implementation UILabel

#pragma mark - 

- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame])) {
        self.userInteractionEnabled = NO;
        self.multipleTouchEnabled = NO;
        self.textAlignment = UITextAlignmentLeft;
        self.lineBreakMode = UILineBreakModeTailTruncation;
        self.textColor = [UIColor blackColor];
        self.backgroundColor = [UIColor clearColor];
        self.enabled = YES;
        self.font = [UIFont systemFontOfSize:17];
        self.numberOfLines = 1;
        self.contentMode = UIViewContentModeLeft;
        self.clipsToBounds = YES;
        self.shadowOffset = CGSizeMake(0,-1);
        self.baselineAdjustment = UIBaselineAdjustmentAlignBaselines;
        self.minimumScaleFactor = 1.0;
    }
    return self;
}
- (void)dealloc
{
    if (_framesetter) {
        CFRelease(_framesetter);
    }
    if (_highlightFramesetter) {
        CFRelease(_highlightFramesetter);
    }
}

#pragma mark -

- (void)setAttributedText:(NSAttributedString *)newAttributedText
{
    if (![newAttributedText isEqualToAttributedString:_attributedText]) {
        _attributedText = [newAttributedText copy];
        [self setNeedsFramesetter];
        [self setNeedsDisplay];
    }
}

- (void)setText:(NSString *)newText
{
    if (_text != newText) {
        _text = [newText copy];
        [self setNeedsFramesetter];
        [self setNeedsDisplay];
    }
}

- (void)setFont:(UIFont *)newFont
{
    assert(newFont != nil);

    if (newFont != _font) {
        _font = newFont;
        [self setNeedsDisplay];
    }
}

- (void)setTextColor:(UIColor *)newColor
{
    if (newColor != _textColor) {
        _textColor = newColor;
        [self setNeedsDisplay];
    }
}

- (void)setShadowColor:(UIColor *)newColor
{
    if (newColor != _shadowColor) {
        _shadowColor = newColor;
        [self setNeedsDisplay];
    }
}

- (void)setShadowOffset:(CGSize)newOffset
{
    if (!CGSizeEqualToSize(newOffset,_shadowOffset)) {
        _shadowOffset = newOffset;
        [self setNeedsDisplay];
    }
}

- (void)setTextAlignment:(UITextAlignment)newAlignment
{
    if (newAlignment != _textAlignment) {
        _textAlignment = newAlignment;
        [self setNeedsDisplay];
    }
}

- (void)setLineBreakMode:(UILineBreakMode)newMode
{
    if (newMode != _lineBreakMode) {
        _lineBreakMode = newMode;
        [self setNeedsDisplay];
    }
}

- (void)setEnabled:(BOOL)newEnabled
{
    if (newEnabled != _enabled) {
        _enabled = newEnabled;
        [self setNeedsDisplay];
    }
}

- (void)setNumberOfLines:(NSInteger)lines
{
    if (lines != _numberOfLines) {
        _numberOfLines = lines;
        [self setNeedsDisplay];
    }
}

- (void)setBaselineAdjustment:(UIBaselineAdjustment)baselineAdjustment
{
    if (baselineAdjustment != _baselineAdjustment) {
        _baselineAdjustment = baselineAdjustment;
        [self setNeedsDisplay];
    }
}

- (void)setAdjustsFontSizeToFitWidth:(BOOL)adjustsFontSizeToFitWidth
{
    if (adjustsFontSizeToFitWidth != _adjustsFontSizeToFitWidth) {
        _adjustsFontSizeToFitWidth = adjustsFontSizeToFitWidth;
        [self setNeedsDisplay];
    }
}

- (void)setMinimumScaleFactor:(CGFloat)minimumScaleFactor
{
    if (minimumScaleFactor != _minimumScaleFactor) {
        _minimumScaleFactor = minimumScaleFactor;
        [self setNeedsDisplay];
    }
}

- (void)setHighlighted:(BOOL)highlighted
{
    if (highlighted != _highlighted) {
        _highlighted = highlighted;
        [self setNeedsDisplay];
    }
}

- (void)setFrame:(CGRect)newFrame
{
    const BOOL redisplay = !CGSizeEqualToSize(newFrame.size,self.frame.size);
    [super setFrame:newFrame];
    if (redisplay) {
        [self setNeedsDisplay];
    }
}

#pragma mark -

- (CGRect)textRectForBounds:(CGRect)bounds limitedToNumberOfLines:(NSInteger)numberOfLines
{
    CGRect textRect = bounds;
    
    // Adjust the text to be in the center vertically, if the text size is smaller than bounds
    
    CGSize textSize = CTFramesetterSuggestFrameSizeForAttributedStringWithConstraints([self framesetter],
                                                                                      self.attributedTextForDrawing,
                                                                                      textRect.size,
                                                                                      self.numberOfLines);
    
    if (textSize.height < textRect.size.height) {
        textRect.origin.y -= (bounds.size.height - textSize.height) / 2.0f;
        textRect.size.height = textSize.height;
    }
    
    return textRect;
}

- (CGSize)sizeThatFits:(CGSize)size
{
    if (self.attributedTextForDrawing.length <= 0) {
        return CGSizeZero;
    }
    
    CGSize suggestedSize = CTFramesetterSuggestFrameSizeForAttributedStringWithConstraints([self framesetter], self.attributedTextForDrawing, size, (NSUInteger)self.numberOfLines);
    suggestedSize.width = CGFloat_ceil(MIN(size.width, suggestedSize.width));
    suggestedSize.height = CGFloat_ceil(MIN(size.height, suggestedSize.height));
    return suggestedSize;
}
- (void)sizeToFit
{
    CGSize size = (self.numberOfLines == 1) ? CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) : CGSizeMake(self.bounds.size.width, CGFLOAT_MAX);
    CGRect frame = self.frame;
    frame.size = [self sizeThatFits:size];
    self.frame = frame;
}

#pragma mark -

- (void)drawTextInRect:(CGRect)rect
{
    CGContextSaveGState(UIGraphicsGetCurrentContext());
    CTFramesetterRef framesetter = [self framesetter];
    if(framesetter) {
        CGMutablePathRef path = CGPathCreateMutable();
        CGPathAddRect(path, NULL, CGRectMake(0, 0, rect.size.width, rect.size.height));
        CGContextConcatCTM(UIGraphicsGetCurrentContext(), CGAffineTransformMake(1, 0, 0, -1, 0, self.bounds.size.height));
        CGContextTranslateCTM(UIGraphicsGetCurrentContext(), rect.origin.x, -rect.origin.y);
        CTFrameRef frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, 0), path, NULL);
        CFRelease(path);
        CTFrameDraw(frame, UIGraphicsGetCurrentContext());
        CFRelease(frame);
    }
    CGContextRestoreGState(UIGraphicsGetCurrentContext());
}
- (void)drawRect:(CGRect)rect
{
    CGRect bounds = [self textRectForBounds:self.bounds limitedToNumberOfLines:self.numberOfLines];
    [self drawTextInRect:bounds];
}

#pragma mark - 

- (NSAttributedString *)renderedAttributedText
{
    if (!_renderedAttributedText) {
        _renderedAttributedText = NSAttributedStringBySettingColorFromContext(self.attributedTextForDrawing, self.textColor);
        _renderedAttributedText = [_renderedAttributedText NSCompatibleAttributedStringWithOptions:NSAttributedStringConversionOptionColors];
    }
    return _renderedAttributedText;
}

- (NSAttributedString *)attributedTextForDrawing
{
    if (_attributedText) {
        _attributedTextForDrawing = [_attributedText NSCompatibleAttributedStringWithOptions:NSAttributedStringConversionOptionFonts];
    } else {
        _attributedTextForDrawing = [[NSAttributedString alloc] initWithString:(_text) ? _text : @"" attributes:NSAttributedStringAttributesFromLabel(self)];
    }
    return _attributedTextForDrawing;
}

#pragma mark - 

- (void)setNeedsFramesetter
{
    // Reset the rendered attributed text so it has a chance to regenerate
    self.renderedAttributedText = nil;
    self.attributedTextForDrawing = nil;
    
    _needsFramesetter = YES;
}

- (CTFramesetterRef)framesetter
{
    if (_needsFramesetter) {
        @synchronized(self) {
            CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)self.renderedAttributedText);
            [self setFramesetter:framesetter];
            [self setHighlightFramesetter:nil];
            _needsFramesetter = NO;
            
            if (framesetter) {
                CFRelease(framesetter);
            }
        }
    }
    
    return _framesetter;
}

- (void)setFramesetter:(CTFramesetterRef)framesetter
{
    if (framesetter) {
        CFRetain(framesetter);
    }
    
    if (_framesetter) {
        CFRelease(_framesetter);
    }
    
    _framesetter = framesetter;
}

- (CTFramesetterRef)highlightFramesetter
{
    return _highlightFramesetter;
}

- (void)setHighlightFramesetter:(CTFramesetterRef)highlightFramesetter
{
    if (highlightFramesetter) {
        CFRetain(highlightFramesetter);
    }
    
    if (_highlightFramesetter) {
        CFRelease(_highlightFramesetter);
    }
    
    _highlightFramesetter = highlightFramesetter;
}

@end
