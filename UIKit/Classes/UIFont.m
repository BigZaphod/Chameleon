//  Created by Sean Heber on 6/17/10.
#import "UIFont.h"
#import <Cocoa/Cocoa.h>

static NSString *UIFontSystemFontName = nil;
static NSString *UIFontBoldSystemFontName = nil;

@implementation UIFont

+ (void)setSystemFontName:(NSString *)aName
{
	[UIFontSystemFontName release];
	UIFontSystemFontName = [aName copy];
}

+ (void)setBoldSystemFontName:(NSString *)aName
{
	[UIFontBoldSystemFontName release];
	UIFontBoldSystemFontName = [aName copy];
}

+ (UIFont *)_fontWithCTFont:(CTFontRef)aFont
{
	UIFont *theFont = [[UIFont alloc] init];
	theFont->_font = CFRetain(aFont);
	return [theFont autorelease];
}

+ (UIFont *)fontWithNSFont:(NSFont *)aFont
{
	if (aFont) {
		CTFontRef newFont = CTFontCreateWithName((CFStringRef)[aFont fontName], [aFont pointSize], NULL);
		if (newFont) {
			UIFont *theFont = [self _fontWithCTFont:newFont];
			CFRelease(newFont);
			return theFont;
		}
	}
	return nil;
}

+ (UIFont *)fontWithName:(NSString *)fontName size:(CGFloat)fontSize
{
	return [self fontWithNSFont:[NSFont fontWithName:fontName size:fontSize]];
}

+ (UIFont *)systemFontOfSize:(CGFloat)fontSize
{
	NSFont *systemFont = UIFontSystemFontName? [NSFont fontWithName:UIFontSystemFontName size:fontSize] : [NSFont systemFontOfSize:fontSize];
	return [self fontWithNSFont:systemFont];
}

+ (UIFont *)boldSystemFontOfSize:(CGFloat)fontSize
{
	NSFont *systemFont = UIFontBoldSystemFontName? [NSFont fontWithName:UIFontBoldSystemFontName size:fontSize] : [NSFont boldSystemFontOfSize:fontSize];
	return [self fontWithNSFont:systemFont];
}

- (void)dealloc
{
	CFRelease(_font);
	[super dealloc];
}

- (NSString *)fontName
{
	return [(NSString *)CTFontCopyFullName(_font) autorelease];
}

- (CGFloat)ascender
{
	return CTFontGetAscent(_font);
}

- (CGFloat)descender
{
	return -CTFontGetDescent(_font);
}

- (CGFloat)pointSize
{
	return CTFontGetSize(_font);
}

- (CGFloat)xHeight
{
	return CTFontGetXHeight(_font);
}

- (CGFloat)capHeight
{
	return CTFontGetCapHeight(_font);
}

- (CGFloat)leading
{
	// Updated: iOS 4.0 deprecated -leading and added -lineHeight which seems to be what -leading was doing previously.
	// They kind of walked themselves into a corner here... maybe in a future OS -leading will become the real leading
	// value of the font instead.
	return self.lineHeight;
}

- (CGFloat)lineHeight
{
	// This was added in iOS 4.
	// After much experimentaiton, this seemed to be what is going on in the real UIKit at the time of this writing.
	return roundf(self.xHeight + self.ascender + self.descender + CTFontGetLeading(_font) + 1.f);
}

- (NSString *)familyName
{
	return [(NSString *)CTFontCopyFamilyName(_font) autorelease];
}

- (UIFont *)fontWithSize:(CGFloat)fontSize
{
	CTFontRef newFont = CTFontCreateCopyWithAttributes(_font, fontSize, NULL, NULL);
	if (newFont) {
		UIFont *theFont = [isa _fontWithCTFont:newFont];
		CFRelease(newFont);
		return theFont;
	} else {
		return nil;
	}
}

- (NSFont *)NSFont
{
	return [NSFont fontWithName:self.fontName size:self.pointSize];
}

@end
