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
    
    // create frame
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, CGRectMake(0.0f, 0.0f, constraints.width, UILABEL_FLOAT_MAX));
    CTFrameRef frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, 0), path, NULL);
    
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
            
            CGFloat lineWidth = origin.x + width - trailingWidth;
            CGFloat lineMaxY = constraints.height - origin.y + descent;
            
            suggestedSize.width = MAX(suggestedSize.width, lineWidth);
            suggestedSize.height = MAX(suggestedSize.height, lineMaxY);
            
            if (numberOfLines > 0 && i + 1 == numberOfLines) {
                break;
            }
            
        }
        
        free(linesOrigins);
    }
  
    suggestedSize = CGSizeMake(CGFloat_ceil(suggestedSize.width), CGFloat_ceil(suggestedSize.height));
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
    textSize = CGSizeMake(CGFloat_ceil(textSize.width), CGFloat_ceil(textSize.height)); // Fix for iOS 4, CTFramesetterSuggestFrameSizeWithConstraints sometimes returns fractional sizes
    
    if (textSize.height < textRect.size.height) {
        CGFloat yOffset = CGFloat_ceil((bounds.size.height - textSize.height) / 2.0f);
        textRect.origin.y -= yOffset;
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
    suggestedSize.width = MIN(size.width, suggestedSize.width);
    suggestedSize.height = MIN(size.height, suggestedSize.height);
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
    if ([self.attributedTextForDrawing length] == 0) {
        return;
    }
    
    NSAttributedString *originalAttributedText = nil;
    
    // Adjust the font size to fit width, if necessarry
    if (self.adjustsFontSizeToFitWidth && self.numberOfLines > 0) {
        // Use infinite width to find the max width, which will be compared to availableWidth if needed.
        CGSize maxSize = (self.numberOfLines > 1) ? CGSizeMake(UILABEL_FLOAT_MAX, UILABEL_FLOAT_MAX) : CGSizeZero;
        
        CGFloat textWidth = [self sizeThatFits:maxSize].width;
        CGFloat availableWidth = self.frame.size.width * self.numberOfLines;
        if (self.numberOfLines > 1 && self.lineBreakMode == UILineBreakModeWordWrap) {
            textWidth *= kUILabelLineBreakWordWrapTextWidthScalingFactor;
        }
        
        if (textWidth > availableWidth && textWidth > 0.0f) {
            originalAttributedText = [self.attributedTextForDrawing copy];
            
            CGFloat scaleFactor = availableWidth / textWidth;
            if ([self respondsToSelector:@selector(minimumScaleFactor)] && self.minimumScaleFactor > scaleFactor) {
                scaleFactor = self.minimumScaleFactor;
            }
            
            self.attributedTextForDrawing = NSAttributedStringByScalingFontSize(self.attributedTextForDrawing, scaleFactor);
        }
    }
    
    CGContextRef c = UIGraphicsGetCurrentContext();
    CGContextSaveGState(c);
    {
        CGContextSetTextMatrix(c, CGAffineTransformIdentity);
        
        // Inverts the CTM to match iOS coordinates (otherwise text draws upside-down; Mac OS's system is different)
        CGContextScaleCTM(c, 1.0f, -1.0f);
        
        CFRange textRange = CFRangeMake(0, (CFIndex)[self.attributedTextForDrawing length]);
        
        // First, get the text rect (which takes vertical centering into account)
        CGRect textRect = [self textRectForBounds:rect limitedToNumberOfLines:self.numberOfLines];
        
        // CoreText draws it's text aligned to the bottom, so we move the CTM here to take our vertical offsets into account
        CGContextTranslateCTM(c, 0.0, textRect.origin.y - textRect.size.height);
        
        // Second, trace the shadow before the actual text, if we have one
        if (self.shadowColor && !self.highlighted) {
            CGContextSetShadowWithColor(c, self.shadowOffset, 0, [self.shadowColor CGColor]);
        }
        
        // Finally, draw the text or highlighted text itself (on top of the shadow, if there is one)
        if (self.highlightedTextColor && self.highlighted) {
            NSMutableAttributedString *highlightAttributedString = [self.renderedAttributedText mutableCopy];
            [highlightAttributedString addAttribute:(__bridge NSString *)kCTForegroundColorAttributeName value:(id)[self.highlightedTextColor CGColor] range:NSMakeRange(0, highlightAttributedString.length)];
            
            if (![self highlightFramesetter]) {
                CTFramesetterRef highlightFramesetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)highlightAttributedString);
                [self setHighlightFramesetter:highlightFramesetter];
                CFRelease(highlightFramesetter);
            }
            
            [self drawFramesetter:[self highlightFramesetter] attributedString:highlightAttributedString textRange:textRange inRect:textRect context:c];
        } else {
            [self drawFramesetter:[self framesetter] attributedString:self.renderedAttributedText textRange:textRange inRect:textRect context:c];
        }
        
        // If we adjusted the font size, set it back to its original size
        if (originalAttributedText) {
            // Use ivar directly to avoid clearing out framesetter and renderedAttributedText
            self.attributedTextForDrawing = originalAttributedText;
        }
    }
    CGContextRestoreGState(c);
}

- (void)drawRect:(CGRect)rect
{
    [self drawTextInRect:self.bounds];
}

- (void)drawFramesetter:(CTFramesetterRef)framesetter
       attributedString:(NSAttributedString *)attributedString
              textRange:(CFRange)textRange
                 inRect:(CGRect)rect
                context:(CGContextRef)c
{
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL, rect);
    CTFrameRef frame = CTFramesetterCreateFrame(framesetter, textRange, path, NULL);
    
    [self drawBackground:frame inRect:rect context:c];
    
    CFArrayRef lines = CTFrameGetLines(frame);
    NSInteger numberOfLines = self.numberOfLines > 0 ? MIN(self.numberOfLines, CFArrayGetCount(lines)) : CFArrayGetCount(lines);
    BOOL truncateLastLine = (self.lineBreakMode == UILineBreakModeHeadTruncation || self.lineBreakMode == UILineBreakModeMiddleTruncation || self.lineBreakMode == UILineBreakModeTailTruncation);
    
    CGPoint lineOrigins[numberOfLines];
    CTFrameGetLineOrigins(frame, CFRangeMake(0, numberOfLines), lineOrigins);
    
    for (CFIndex lineIndex = 0; lineIndex < numberOfLines; lineIndex++) {
        CGPoint lineOrigin = lineOrigins[lineIndex];
        lineOrigin = CGPointMake(CGFloat_ceil(lineOrigin.x), CGFloat_ceil(lineOrigin.y));
        
        CGContextSetTextPosition(c, lineOrigin.x, lineOrigin.y);
        CTLineRef line = CFArrayGetValueAtIndex(lines, lineIndex);
        
        CGFloat descent = 0.0f;
        CGFloat leading = 0.0f;
        CTLineGetTypographicBounds((CTLineRef)line, NULL, &descent, &leading);
        
        // Adjust pen offset for flush depending on text alignment
        CGFloat flushFactor = UILabelFlushFactorForTextAlignment(self.textAlignment);
        
        if (lineIndex == numberOfLines - 1 && truncateLastLine) {
            // Check if the range of text in the last line reaches the end of the full attributed string
            CFRange lastLineRange = CTLineGetStringRange(line);
            
            if (!(lastLineRange.length == 0 && lastLineRange.location == 0) && lastLineRange.location + lastLineRange.length < textRange.location + textRange.length) {
                // Get correct truncationType and attribute position
                CTLineTruncationType truncationType;
                CFIndex truncationAttributePosition = lastLineRange.location;
                UILineBreakMode lineBreakMode = self.lineBreakMode;
                
                switch (lineBreakMode) {
                    case UILineBreakModeHeadTruncation:
                        truncationType = kCTLineTruncationStart;
                        break;
                    case UILineBreakModeMiddleTruncation:
                        truncationType = kCTLineTruncationMiddle;
                        truncationAttributePosition += (lastLineRange.length / 2);
                        break;
                    case UILineBreakModeTailTruncation:
                    default:
                        truncationType = kCTLineTruncationEnd;
                        truncationAttributePosition += (lastLineRange.length - 1);
                        break;
                }
                
                NSString *truncationTokenString = @"\u2026"; // Unicode Character 'HORIZONTAL ELLIPSIS' (U+2026)
                NSDictionary *truncationTokenStringAttributes = [attributedString attributesAtIndex:(NSUInteger)truncationAttributePosition effectiveRange:NULL];
                
                NSAttributedString *attributedTokenString = [[NSAttributedString alloc] initWithString:truncationTokenString attributes:truncationTokenStringAttributes];
                CTLineRef truncationToken = CTLineCreateWithAttributedString((__bridge CFAttributedStringRef)attributedTokenString);
                
                // both these methods seem to work just fine
                // except that in 10.6/10.7 the CTLineGetBoundsWithOptions isn't available
                // figure the newer method is more accurate and thus am using it as appropriate
                CGFloat lineWidth = rect.size.width;
                if(&CTLineGetBoundsWithOptions) {
                    lineWidth = CTLineGetBoundsWithOptions(line, kCTLineBoundsUseGlyphPathBounds).size.width;
                } else {
                    lineWidth = CTLineGetImageBounds(line, c).size.width;
                }
                
                // Truncate the line in case it is too long.
                CTLineRef truncatedLine = CTLineCreateTruncatedLine(line, MIN(rect.size.width, lineWidth), truncationType, truncationToken);
                if (!truncatedLine) {
                    // If the line is not as wide as the truncationToken, truncatedLine is NULL
                    truncatedLine = CFRetain(line);
                }
                
                CGFloat penOffset = (CGFloat)CTLineGetPenOffsetForFlush(truncatedLine, flushFactor, rect.size.width);
                CGContextSetTextPosition(c, penOffset, lineOrigin.y - descent - self.font.descender);
                
                CTLineDraw(truncatedLine, c);
                
                CFRelease(truncatedLine);
                CFRelease(truncationToken);
            } else {
                CGFloat penOffset = (CGFloat)CTLineGetPenOffsetForFlush(line, flushFactor, rect.size.width);
                CGContextSetTextPosition(c, penOffset, lineOrigin.y - descent - self.font.descender);
                CTLineDraw(line, c);
            }
        } else {
            CGFloat penOffset = (CGFloat)CTLineGetPenOffsetForFlush(line, flushFactor, rect.size.width);
            CGContextSetTextPosition(c, penOffset, lineOrigin.y - descent - self.font.descender);
            CTLineDraw(line, c);
        }
    }
    
    [self drawStrike:frame inRect:rect context:c];
    
    CFRelease(frame);
    CFRelease(path);
}
- (void)drawBackground:(CTFrameRef)frame
                inRect:(CGRect)rect
               context:(CGContextRef)c
{
    NSArray *lines = (__bridge NSArray *)CTFrameGetLines(frame);
    CGPoint origins[[lines count]];
    CTFrameGetLineOrigins(frame, CFRangeMake(0, 0), origins);
    
    // Adjust pen offset for flush depending on text alignment
    CGFloat flushFactor = UILabelFlushFactorForTextAlignment(self.textAlignment);
    
    CFIndex lineIndex = 0;
    for (id line in lines) {
        CGFloat ascent = 0.0f, descent = 0.0f, leading = 0.0f;
        CGFloat width = (CGFloat)CTLineGetTypographicBounds((__bridge CTLineRef)line, &ascent, &descent, &leading) ;
        CGRect lineBounds = CGRectMake(rect.origin.x, rect.origin.y, width, ascent + descent + leading) ;
        
        CGFloat penOffset = (CGFloat)CTLineGetPenOffsetForFlush((__bridge CTLineRef)line, flushFactor, rect.size.width);
        
        lineBounds.origin.x += origins[lineIndex].x;
        lineBounds.origin.y += origins[lineIndex].y;
        
        for (id glyphRun in (__bridge NSArray *)CTLineGetGlyphRuns((__bridge CTLineRef)line)) {
            NSDictionary *attributes = (__bridge NSDictionary *)CTRunGetAttributes((__bridge CTRunRef) glyphRun);
            CGColorRef fillColor = [[attributes objectForKey:NSBackgroundColorAttributeName] CGColor];
            
            if (fillColor) {
                CGRect runBounds = CGRectZero;
                CGFloat runAscent = 0.0f;
                CGFloat runDescent = 0.0f;
                
                runBounds.size.width = (CGFloat)CTRunGetTypographicBounds((__bridge CTRunRef)glyphRun, CFRangeMake(0, 0), &runAscent, &runDescent, NULL);
                runBounds.size.height = runAscent + runDescent;
                
                CGFloat xOffset = 0.0f;
                CFRange glyphRange = CTRunGetStringRange((__bridge CTRunRef)glyphRun);
                switch (CTRunGetStatus((__bridge CTRunRef)glyphRun)) {
                    case kCTRunStatusRightToLeft:
                        xOffset = CTLineGetOffsetForStringIndex((__bridge CTLineRef)line, glyphRange.location + glyphRange.length, NULL);
                        break;
                    default:
                        xOffset = CTLineGetOffsetForStringIndex((__bridge CTLineRef)line, glyphRange.location, NULL);
                        break;
                }
                
                runBounds.origin.x = penOffset + rect.origin.x + xOffset - rect.origin.x;
                runBounds.origin.y = origins[lineIndex].y + rect.origin.y - rect.origin.y;
                runBounds.origin.y -= runDescent;
                
                // Don't draw higlightedLinkBackground too far to the right
                if (CGRectGetWidth(runBounds) > CGRectGetWidth(lineBounds)) {
                    runBounds.size.width = CGRectGetWidth(lineBounds);
                }
                
                if (fillColor) {
                    CGRect r = runBounds;
                    r.size.width += 1;
                    r.origin.x -= 1;
                    r.origin.y -= 0.5;
                    CGContextSetFillColorWithColor(c, fillColor);
                    CGContextFillRect(c, r);
                    CGContextFillPath(c);
                }
            }
        }
        
        lineIndex++;
    }
}
- (void)drawStrike:(CTFrameRef)frame
            inRect:(__unused CGRect)rect
           context:(CGContextRef)c
{
    NSArray *lines = (__bridge NSArray *)CTFrameGetLines(frame);
    CGPoint origins[[lines count]];
    CTFrameGetLineOrigins(frame, CFRangeMake(0, 0), origins);
    
    // Adjust pen offset for flush depending on text alignment
    CGFloat flushFactor = UILabelFlushFactorForTextAlignment(self.textAlignment);
    
    CFIndex lineIndex = 0;
    for (id line in lines) {
        CGFloat ascent = 0.0f, descent = 0.0f, leading = 0.0f;
        CGFloat width = (CGFloat)CTLineGetTypographicBounds((__bridge CTLineRef)line, &ascent, &descent, &leading) ;
        CGRect lineBounds = CGRectMake(0.0f, 0.0f, width, ascent + descent + leading) ;
        lineBounds.origin.x = origins[lineIndex].x;
        lineBounds.origin.y = origins[lineIndex].y;
        
        CGFloat penOffset = (CGFloat)CTLineGetPenOffsetForFlush((__bridge CTLineRef)line, flushFactor, rect.size.width);
        
        for (id glyphRun in (__bridge NSArray *)CTLineGetGlyphRuns((__bridge CTLineRef)line)) {
            NSDictionary *attributes = (__bridge NSDictionary *)CTRunGetAttributes((__bridge CTRunRef) glyphRun);
            BOOL strikeOut = (attributes[NSStrikethroughStyleAttributeName] != NSUnderlineStyleNone);
            NSInteger superscriptStyle = [attributes[NSSuperscriptAttributeName] integerValue];
            
            if (strikeOut) {
                CGRect runBounds = CGRectZero;
                CGFloat runAscent = 0.0f;
                CGFloat runDescent = 0.0f;
                
                runBounds.size.width = (CGFloat)CTRunGetTypographicBounds((__bridge CTRunRef)glyphRun, CFRangeMake(0, 0), &runAscent, &runDescent, NULL);
                runBounds.size.height = runAscent + runDescent;
                
                CGFloat xOffset = 0.0f;
                CFRange glyphRange = CTRunGetStringRange((__bridge CTRunRef)glyphRun);
                switch (CTRunGetStatus((__bridge CTRunRef)glyphRun)) {
                    case kCTRunStatusRightToLeft:
                        xOffset = CTLineGetOffsetForStringIndex((__bridge CTLineRef)line, glyphRange.location + glyphRange.length, NULL);
                        break;
                    default:
                        xOffset = CTLineGetOffsetForStringIndex((__bridge CTLineRef)line, glyphRange.location, NULL);
                        break;
                }
                runBounds.origin.x = penOffset + xOffset;
                runBounds.origin.y = origins[lineIndex].y;
                runBounds.origin.y -= runDescent;
                
                // Don't draw strikeout too far to the right
                if (CGRectGetWidth(runBounds) > CGRectGetWidth(lineBounds)) {
                    runBounds.size.width = CGRectGetWidth(lineBounds);
                }
                
				switch (superscriptStyle) {
					case 1:
						runBounds.origin.y -= runAscent * 0.47f;
						break;
					case -1:
						runBounds.origin.y += runAscent * 0.25f;
						break;
					default:
						break;
				}
                
                // Use text color, or default to black
                id color = attributes[NSStrikethroughColorAttributeName];
                if (color) {
                    if ([color isKindOfClass:[UIColor class]]) {
                        CGContextSetStrokeColorWithColor(c, [color CGColor]);
                    } else {
                        CGContextSetStrokeColorWithColor(c, (__bridge CGColorRef)color);
                    }
                } else {
                    CGContextSetGrayStrokeColor(c, 0.0f, 1.0);
                }
                
                CTFontRef font = CTFontCreateWithName((__bridge CFStringRef)self.font.fontName, self.font.pointSize, NULL);
                CGContextSetLineWidth(c, CTFontGetUnderlineThickness(font));
                CFRelease(font);
                
                CGFloat y = CGFloat_round(runBounds.origin.y + runBounds.size.height / 2.0f);
                CGContextMoveToPoint(c, runBounds.origin.x, y);
                CGContextAddLineToPoint(c, runBounds.origin.x + runBounds.size.width, y);
                
                CGContextStrokePath(c);
            }
        }
        
        lineIndex++;
    }
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
