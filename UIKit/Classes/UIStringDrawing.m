//  Created by Sean Heber on 6/17/10.
#import "UIStringDrawing.h"
#import "UIFont.h"
#import <AppKit/AppKit.h>
#import "UIGraphics.h"

static CFArrayRef CreateCTLinesForString(NSString *string, CGSize constrainedToSize, UIFont *font, UILineBreakMode lineBreakMode, CGSize *renderSize)
{
	CFMutableArrayRef lines = CFArrayCreateMutable(NULL, 0, &kCFTypeArrayCallBacks);
	
	CFMutableDictionaryRef attributes = CFDictionaryCreateMutable(NULL, 2, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
	CFDictionarySetValue(attributes, kCTFontAttributeName,font->_font);
	CFDictionarySetValue(attributes, kCTForegroundColorFromContextAttributeName, kCFBooleanTrue);
	
	CFAttributedStringRef attributedString = CFAttributedStringCreate(NULL, (CFStringRef)string, attributes);
	
	CTTypesetterRef typesetter = CTTypesetterCreateWithAttributedString(attributedString);
	
	const CFIndex stringLength = CFAttributedStringGetLength(attributedString);
	const CGFloat leading = font.leading;
	const CGFloat capHeight = font.capHeight;
	
	CFIndex start = 0;
	BOOL isLastLine = NO;
	CGSize drawSize = CGSizeZero;
	
	while (start < stringLength && !isLastLine) {
		drawSize.height += leading;
		isLastLine = (drawSize.height+capHeight >= constrainedToSize.height);
		
		CFIndex usedCharacters = 0;
		CTLineRef line = NULL;
		
		if (isLastLine && (lineBreakMode != UILineBreakModeWordWrap && lineBreakMode != UILineBreakModeCharacterWrap)) {
			if (lineBreakMode == UILineBreakModeClip) {
				usedCharacters = CTTypesetterSuggestClusterBreak(typesetter, start, constrainedToSize.width);
				line = CTTypesetterCreateLine(typesetter, CFRangeMake(start, usedCharacters));
			} else {
				CTLineTruncationType truncType;
				
				if (lineBreakMode == UILineBreakModeHeadTruncation) {
					truncType = kCTLineTruncationStart;
				} else if (lineBreakMode == UILineBreakModeTailTruncation) {
					truncType = kCTLineTruncationEnd;
				} else {
					truncType = kCTLineTruncationMiddle;
				}
				
				usedCharacters = stringLength - start;
				CFAttributedStringRef ellipsisString = CFAttributedStringCreate(NULL, CFSTR("…"), attributes);
				CTLineRef ellipsisLine = CTLineCreateWithAttributedString(ellipsisString);
				CTLineRef tempLine = CTTypesetterCreateLine(typesetter, CFRangeMake(start, usedCharacters));
				line = CTLineCreateTruncatedLine(tempLine, constrainedToSize.width, truncType, ellipsisLine);
				CFRelease(tempLine);
				CFRelease(ellipsisLine);
				CFRelease(ellipsisString);
			}
		} else {
			if (lineBreakMode == UILineBreakModeCharacterWrap) {
				usedCharacters = CTTypesetterSuggestClusterBreak(typesetter, start, constrainedToSize.width);
			} else {
				usedCharacters = CTTypesetterSuggestLineBreak(typesetter, start, constrainedToSize.width);
			}
			line = CTTypesetterCreateLine(typesetter, CFRangeMake(start, usedCharacters));
		}
		
		if (line) {
			drawSize.width = MAX(drawSize.width, ceilf(CTLineGetTypographicBounds(line,NULL,NULL,NULL)));
			
			CFArrayAppendValue(lines, line);
			CFRelease(line);
		}
		
		start += usedCharacters;
	}
	
	CFRelease(typesetter);
	CFRelease(attributedString);
	CFRelease(attributes);
	
	if (renderSize) {
		*renderSize = drawSize;
	}
	
	return lines;
}

@implementation NSString (UIStringDrawing)

- (CGSize)sizeWithFont:(UIFont *)font
{
	return [self sizeWithFont:font constrainedToSize:CGSizeMake(CGFLOAT_MAX,font.leading)];
}

- (CGSize)sizeWithFont:(UIFont *)font forWidth:(CGFloat)width lineBreakMode:(UILineBreakMode)lineBreakMode
{
	return [self sizeWithFont:font constrainedToSize:CGSizeMake(width,font.leading) lineBreakMode:lineBreakMode];
}

- (CGSize)sizeWithFont:(UIFont *)font minFontSize:(CGFloat)minFontSize actualFontSize:(CGFloat *)actualFontSize forWidth:(CGFloat)width lineBreakMode:(UILineBreakMode)lineBreakMode
{
	return CGSizeZero;
}

- (CGSize)sizeWithFont:(UIFont *)font constrainedToSize:(CGSize)size lineBreakMode:(UILineBreakMode)lineBreakMode
{
	CGSize resultingSize = CGSizeZero;
	
	CFArrayRef lines = CreateCTLinesForString(self, size, font, lineBreakMode, &resultingSize);
	if (lines) CFRelease(lines);
	
	return resultingSize;
}

- (CGSize)sizeWithFont:(UIFont *)font constrainedToSize:(CGSize)size
{
	return [self sizeWithFont:font constrainedToSize:size lineBreakMode:UILineBreakModeWordWrap];
}

- (CGSize)drawAtPoint:(CGPoint)point withFont:(UIFont *)font
{
	return [self drawAtPoint:point forWidth:CGFLOAT_MAX withFont:font lineBreakMode:UILineBreakModeWordWrap];
}

- (CGSize)drawAtPoint:(CGPoint)point forWidth:(CGFloat)width withFont:(UIFont *)font minFontSize:(CGFloat)minFontSize actualFontSize:(CGFloat *)actualFontSize lineBreakMode:(UILineBreakMode)lineBreakMode baselineAdjustment:(UIBaselineAdjustment)baselineAdjustment
{
	return CGSizeZero;
}

- (CGSize)drawAtPoint:(CGPoint)point forWidth:(CGFloat)width withFont:(UIFont *)font fontSize:(CGFloat)fontSize lineBreakMode:(UILineBreakMode)lineBreakMode baselineAdjustment:(UIBaselineAdjustment)baselineAdjustment
{
	UIFont *adjustedFont = ([font pointSize] != fontSize)? [font fontWithSize:fontSize] : font;
	return [self drawInRect:CGRectMake(point.x,point.y,width,adjustedFont.leading) withFont:adjustedFont lineBreakMode:lineBreakMode];
}

- (CGSize)drawAtPoint:(CGPoint)point forWidth:(CGFloat)width withFont:(UIFont *)font lineBreakMode:(UILineBreakMode)lineBreakMode
{
	return [self drawAtPoint:point forWidth:width withFont:font fontSize:[font pointSize] lineBreakMode:lineBreakMode baselineAdjustment:UIBaselineAdjustmentNone];
}
 
- (CGSize)drawInRect:(CGRect)rect withFont:(UIFont *)font lineBreakMode:(UILineBreakMode)lineBreakMode alignment:(UITextAlignment)alignment
{
	CGSize actualSize = CGSizeZero;
	CFArrayRef lines = CreateCTLinesForString(self,rect.size,font,lineBreakMode,&actualSize);

	if (lines) {
		const CFIndex numberOfLines = CFArrayGetCount(lines);
		const CGFloat fontLeading = font.leading;
		CGFloat textOffset = 0;

		CGContextRef ctx = UIGraphicsGetCurrentContext();
		CGContextSaveGState(ctx);
		CGContextTranslateCTM(ctx, rect.origin.x, rect.origin.y+font.ascender);
		CGContextSetTextMatrix(ctx, CGAffineTransformMakeScale(1,-1));
		
		for (CFIndex lineNumber=0; lineNumber<numberOfLines; lineNumber++) {
			CTLineRef line = CFArrayGetValueAtIndex(lines, lineNumber);
			float flush;
			switch (alignment) {
				case UITextAlignmentCenter:	flush = 0.5;	break;
				case UITextAlignmentRight:	flush = 1;		break;
				case UITextAlignmentLeft:
				default:					flush = 0;		break;
			}
			
			CGFloat penOffset = CTLineGetPenOffsetForFlush(line, flush, rect.size.width);
			CGContextSetTextPosition(ctx, penOffset, textOffset);
			CTLineDraw(line, ctx);
			textOffset += fontLeading;
		}

		CGContextRestoreGState(ctx);

		CFRelease(lines);
	}

	// the real UIKit appears to do this.. so shall we.
	actualSize.height = MIN(actualSize.height, rect.size.height);

	return actualSize;
}

- (CGSize)drawInRect:(CGRect)rect withFont:(UIFont *)font
{
	return [self drawInRect:rect withFont:font lineBreakMode:UILineBreakModeWordWrap alignment:UITextAlignmentLeft];
}

- (CGSize)drawInRect:(CGRect)rect withFont:(UIFont *)font lineBreakMode:(UILineBreakMode)lineBreakMode
{
	return [self drawInRect:rect withFont:font lineBreakMode:lineBreakMode alignment:UITextAlignmentLeft];
}

@end
