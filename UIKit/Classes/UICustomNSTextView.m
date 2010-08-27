//  Created by Sean Heber on 8/26/10.
#import "UICustomNSTextView.h"
#import "UIBulletGlyphGenerator.h"
#import <AppKit/NSLayoutManager.h>
#import <AppKit/NSMenuItem.h>
#import <AppKit/NSMenu.h>

const CGFloat UILargeNumberForText = 1.0e7; // Any larger dimensions and the text could become blurry.

@implementation UICustomNSTextView

- (id)initWithFrame:(NSRect)frame secureTextEntry:(BOOL)isSecure
{
	if ((self=[super initWithFrame:frame])) {
		[self setWantsLayer:YES];
		[self setMaxSize:NSMakeSize(UILargeNumberForText, UILargeNumberForText)];
		[self setHorizontallyResizable:NO];
		[self setVerticallyResizable:YES];
		[self setAutoresizingMask:NSViewWidthSizable];
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

- (void)setSecureTextEntry:(BOOL)isSecure
{
	secureTextEntry = isSecure;

	NSMutableParagraphStyle *style = [NSMutableParagraphStyle new];
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
		[[self layoutManager] setGlyphGenerator:[[UIBulletGlyphGenerator new] autorelease]];
		[style setLineBreakMode:NSLineBreakByCharWrapping];
	} else {
		[self setSmartInsertDeleteEnabled:YES];
		[self setUsesFindPanel:YES];
		[[self layoutManager] setGlyphGenerator:[NSGlyphGenerator sharedGlyphGenerator]];
	}
	
	[self setDefaultParagraphStyle:style];
	[style release];
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

@end
