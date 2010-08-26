//  Created by Sean Heber on 8/26/10.
#import "UIBulletGlyphGenerator.h"
#import <AppKit/NSAttributedString.h>

@implementation UIBulletGlyphGenerator

- (void)generateGlyphsForGlyphStorage:(id < NSGlyphStorage >)glyphStorage desiredNumberOfCharacters:(NSUInteger)nChars glyphIndex:(NSUInteger *)glyphIndex characterIndex:(NSUInteger *)charIndex
{
	while (nChars > 0) {
		NSFont *font = [[glyphStorage attributedString] attribute:NSFontAttributeName atIndex:*charIndex effectiveRange:NULL];
		NSGlyph g = [font glyphWithName:@"bullet"];
		[glyphStorage insertGlyphs:&g length:1 forStartingGlyphAtIndex:*glyphIndex characterIndex:*charIndex];
		(*charIndex)++;
		(*glyphIndex)++;
		nChars--;
	}
}

@end
