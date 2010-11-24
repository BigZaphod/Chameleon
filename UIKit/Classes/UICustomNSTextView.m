//  Created by Sean Heber on 8/26/10.
#import "UICustomNSTextView.h"
#import "UIBulletGlyphGenerator.h"
#import <AppKit/NSLayoutManager.h>
#import <AppKit/NSTextContainer.h>
#import <AppKit/NSMenuItem.h>
#import <AppKit/NSMenu.h>
#import <AppKit/NSGraphicsContext.h>

static const CGFloat LargeNumberForText = 1.0e7; // Any larger dimensions and the text could become blurry.

@implementation UICustomNSTextView

- (id)initWithFrame:(NSRect)frame secureTextEntry:(BOOL)isSecure isField:(BOOL)isField
{
	if ((self=[super initWithFrame:frame])) {
		const NSSize maxSize = NSMakeSize(LargeNumberForText, LargeNumberForText);
		
		// this is not ideal, I suspect... but it seems to work for now.
		// one behavior that's missing is that when a field resigns first responder,
		// it should really sort of turn back into a non-field that happens to have no word wrapping.
		// right now I have it scroll to the beginning of the line, at least, but even though the line break
		// mode is set to truncate on the tail, it doesn't do that because the underlying text container's size
		// has been sized to something bigger here. I tried to work around this by resetting the modes and such
		// on resignFirstResponder, but for some reason it just didn't seem to work reliably (especially when
		// the view was resized - it's like once you turn off setWidthTracksTextView, it doesn't want to turn
		// back on again). I'm likely missing something important, but it's not crazy important right now.
		if (isField) {
			[self setFieldEditor:YES];
			[self setHorizontallyResizable:YES];
			[self setVerticallyResizable:NO];
			[[self textContainer] setWidthTracksTextView:NO];
			[[self textContainer] setContainerSize:maxSize];
		} else {
			[self setFieldEditor:NO];
			[self setHorizontallyResizable:NO];
			[self setVerticallyResizable:YES];
			[self setAutoresizingMask:NSViewWidthSizable];
		}

		[self setMaxSize:maxSize];
		[self setDrawsBackground:NO];
		[self setRichText:NO];
		[self setUsesFontPanel:NO];
		[self setImportsGraphics:NO];
		[self setAllowsImageEditing:NO];
		[self setDisplaysLinkToolTips:NO];
		[self setAutomaticDataDetectionEnabled:NO];
		[self setSecureTextEntry:isSecure];
	}
	return self;
}

- (void)updateStyles
{
	NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
	[style setParagraphStyle:[NSParagraphStyle defaultParagraphStyle]];
	
	if (secureTextEntry) {
		// being all super-paranoid here...
		[self setAutomaticQuoteSubstitutionEnabled:NO];
		[self setGrammarCheckingEnabled:NO];
		[self setAutomaticSpellingCorrectionEnabled:NO];
		[self setContinuousSpellCheckingEnabled:NO];
		[self setAutomaticDashSubstitutionEnabled:NO];
		[self setAutomaticTextReplacementEnabled:NO];
		[self setSmartInsertDeleteEnabled:NO];
		[self setUsesFindPanel:NO];
		[[self layoutManager] setGlyphGenerator:[[[UIBulletGlyphGenerator alloc] init] autorelease]];
		[style setLineBreakMode:NSLineBreakByCharWrapping];
	} else {
		[self setContinuousSpellCheckingEnabled:YES];
		[self setSmartInsertDeleteEnabled:YES];
		[self setUsesFindPanel:YES];
		[[self layoutManager] setGlyphGenerator:[NSGlyphGenerator sharedGlyphGenerator]];
	}
	
	if ([self isFieldEditor]) {
		[style setLineBreakMode:NSLineBreakByTruncatingTail];
	}
	
	[self setDefaultParagraphStyle:style];
	[style release];
}

- (void)setSecureTextEntry:(BOOL)isSecure
{
	secureTextEntry = isSecure;
	[self updateStyles];
}

- (BOOL)validateMenuItem:(NSMenuItem *)menuItem
{
	if (secureTextEntry && ([menuItem action] == @selector(copy:) || [menuItem action] == @selector(cut:))) {
		return NO;	// don't allow copying/cutting out from a secure field
	} else {
		return [super validateMenuItem:menuItem];
	}
}

- (NSSelectionGranularity)selectionGranularity
{
	if (secureTextEntry) {
		return NSSelectByCharacter;		// trying to avoid the secure one giving any hints about what's under it. :/
	} else {
		return [super selectionGranularity];
	}
}

- (void)startSpeaking:(id)sender
{
	// only allow speaking if it's not secure
	if (!secureTextEntry) {
		[super startSpeaking:sender];
	}
}

- (id)validRequestorForSendType:(NSString *)sendType returnType:(NSString *)returnType
{
	if (secureTextEntry) {
		return nil;
	} else {
		return [super validRequestorForSendType:sendType returnType:returnType];
	}
}

- (NSMenu *)menuForEvent:(NSEvent *)theEvent
{
	NSMenu *menu = [super menuForEvent:theEvent];
	
	// screw it.. why not just remove everything from the context menu if it's a secure field? :)
	// it's possible that various key combos could still allow things like searching in spotlight which
	// then would revel the actual value of the password field, but at least those are sorta obscure :)
	if (secureTextEntry) {
		NSArray *items = [[[menu itemArray] copy] autorelease];
		for (NSMenuItem *item in items) {
			if ([item action] != @selector(paste:)) {
				[menu removeItem:item];
			}
		}
	}
	return menu;
}

- (BOOL)resignFirstResponder
{
	if ([self isFieldEditor]) {
		[self scrollRangeToVisible:NSMakeRange(0,0)];
	}
	[self setSelectedRange:NSMakeRange(0,0)];
	return [super resignFirstResponder];
}

- (void)drawRect:(NSRect)rect
{
	// This disables font smoothing. This is necessary because in this implementation, the NSTextView is always drawn with a transparent background
	// and layered on top of other views. It therefore cannot properly do subpixel rendering and the smoothing ends up looking like crap. Turning
	// the smoothing off is not as nice as properly smoothed text, of course, but at least its readable. :)
	CGContextRef c = [[NSGraphicsContext currentContext] graphicsPort];
	CGContextSetShouldSmoothFonts(c, NO);
	
	[super drawRect:rect];
}

@end
