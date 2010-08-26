//  Created by Sean Heber on 8/23/10.
#import "UIText.h"
#import "UIClipNSView.h"
#import "UIView.h"
#import "UIFont+UIPrivate.h"
#import "UIColor+UIPrivate.h"
#import "UIWindow.h"
#import "UIScreen+UIPrivate.h"
#import <AppKit/NSTextStorage.h>
#import <AppKit/NSTextContainer.h>
#import <AppKit/NSLayoutManager.h>
#import <AppKit/NSTextView.h>
#import <AppKit/NSCursor.h>
#import <AppKit/NSColor.h>
#import <AppKit/NSMenuItem.h>
#import <AppKit/NSMenu.h>
#import <AppKit/NSWindow.h>
#import <AppKit/NSScrollView.h>
#import <AppKit/NSApplication.h>
#import <AppKit/NSEvent.h>
#import <QuartzCore/CALayer.h>
#import <QuartzCore/CATextLayer.h>
#import <QuartzCore/CATransaction.h>
#import "UITextInputTraits.h"


static const CGFloat LargeNumberForText = 1.0e7; // Any larger dimensions and the text could become blurry.


@interface UIBulletGlyphGenerator : NSGlyphGenerator
@end

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





@interface UICustomNSTextView: NSTextView {
	BOOL secureTextEntry;
}
- (id)initWithFrame:(NSRect)frame textContainer:(NSTextContainer *)textContainer secureTextEntry:(BOOL)isSecure;
@end

@implementation UICustomNSTextView
- (id)initWithFrame:(NSRect)frame textContainer:(NSTextContainer *)textContainer secureTextEntry:(BOOL)isSecure
{
	if ((self=[super initWithFrame:frame textContainer:textContainer])) {
		secureTextEntry = isSecure;
		
		[self setMaxSize:NSMakeSize(LargeNumberForText, LargeNumberForText)];
		[self setHorizontallyResizable:NO];
		[self setVerticallyResizable:YES];
		[self setAutoresizingMask:NSViewWidthSizable];
		[self setDrawsBackground:NO];
		[self setRichText:NO];
		[self setUsesFontPanel:NO];
		[self setImportsGraphics:NO];
		[self setAllowsImageEditing:NO];
		[self setDisplaysLinkToolTips:NO];
		
		// extra paranoia and such...
		if (secureTextEntry) {
			[self setAutomaticDataDetectionEnabled:NO];
			[self setSmartInsertDeleteEnabled:NO];
			[self setAutomaticQuoteSubstitutionEnabled:NO];
			[self setUsesRuler:NO];
			[self setGrammarCheckingEnabled:NO];
			[self setAutomaticSpellingCorrectionEnabled:NO];
			[self setContinuousSpellCheckingEnabled:NO];
			[self setUsesFindPanel:NO];
			[self setAutomaticDashSubstitutionEnabled:NO];
			[self setAutomaticTextReplacementEnabled:NO];
		}
	}
	return self;
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





@implementation UIText
@synthesize textColor, font, editable, secureTextEntry;

- (id)initWithContainerView:(id<UITextContainerViewProtocol>)view
{
	if ((self=[super init])) {
		containerView = view;
		
		textStorage = [NSTextStorage new];
		layoutManager = [NSLayoutManager new];

		textContainer = [[NSTextContainer alloc] initWithContainerSize:NSMakeSize([containerView bounds].size.width,LargeNumberForText)];
		[textContainer setWidthTracksTextView:YES];
		[textContainer setHeightTracksTextView:NO];

		[textStorage addLayoutManager:layoutManager];
		[layoutManager addTextContainer:textContainer];
	}
	return self;
}

- (void)setHidden:(BOOL)hidden
{
	[editor setHidden:hidden];
}

- (void)setEditable:(BOOL)edit
{
	if (editable != edit) {
		editable = edit;
		[[editor documentView] setEditable:editable];
	}
}

- (NSParagraphStyle *)paragraphStyle
{
	NSMutableParagraphStyle *style = [NSMutableParagraphStyle new];
	[style setParagraphStyle:[NSParagraphStyle defaultParagraphStyle]];
	if (secureTextEntry) {
		[style setLineBreakMode:NSLineBreakByCharWrapping];
	}
	return [style autorelease];
}

- (void)updateAttributes
{
	NSDictionary *attributes = [[NSDictionary alloc] initWithObjectsAndKeys:
								[font _NSFont],			NSFontAttributeName,
								[textColor _NSColor],	NSForegroundColorAttributeName,
								[self paragraphStyle],	NSParagraphStyleAttributeName,
								nil];
	
	[textStorage setAttributes:attributes range:NSMakeRange(0,[textStorage length])];
	
	[attributes release];
	
	// should only try to force a redisplay is the editor isn't currently active
	if (!editor) {
		[containerView setNeedsDisplay];
	}
}

- (void)setFont:(UIFont *)newFont
{
	NSAssert((newFont != nil), nil);
	if (newFont != font) {
		[font release];
		font = [newFont retain];
		[self updateAttributes];
	}
}

- (void)setTextColor:(UIColor *)newColor
{
	if (newColor != textColor) {
		[textColor release];
		textColor = [newColor retain];
		[self updateAttributes];
	}
}

- (NSString *)text
{
	return [[[textStorage mutableString] copy] autorelease];
}

- (void)setText:(NSString *)newText
{
	[textStorage setAttributedString:[[[NSAttributedString alloc] initWithString:newText] autorelease]];
	[self updateAttributes];
}

- (void)setSecureTextEntry:(BOOL)s
{
	if (s != secureTextEntry) {
		secureTextEntry = s;
		[layoutManager setGlyphGenerator:(secureTextEntry? [[UIBulletGlyphGenerator new] autorelease] : [NSGlyphGenerator sharedGlyphGenerator])];
		[self updateAttributes];
	}
}

- (NSRect)NSViewFrame
{
	const CGRect windowRect = [[containerView window] convertRect:[containerView frame] fromView:[containerView superview]];
	const CGRect screenRect = [[containerView window] convertRect:windowRect toWindow:nil];
	return NSRectFromCGRect(screenRect);
}

- (void)updateFrame
{
	// all we need to do is change the size of the container and mark the view as dirty if there's no editor.
	// if there's an editor, though, we need to move it's view so things line up, but we'll let the NSTextView
	// take care of pretty much everything else.
	if (!editor) {
		[textContainer setContainerSize:NSMakeSize([containerView bounds].size.width, LargeNumberForText)];
		[containerView setNeedsDisplay];
	} else {
		[editor setFrame:[self NSViewFrame]];
	}
}

- (void)containerViewFrameDidChange
{
	[self updateFrame];
}

- (void)removeHierarchyObservers
{
	UIView *view = containerView.superview;
	while (view) {
		[view removeObserver:self forKeyPath:@"superview"];
		[view removeObserver:self forKeyPath:@"frame"];
		view = view.superview;
	}
}

- (void)buildHierarchyObserversForSuperview:(UIView *)view
{
	while (view) {
		[view addObserver:self forKeyPath:@"superview" options:NSKeyValueObservingOptionPrior context:NULL];
		[view addObserver:self forKeyPath:@"frame" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:NULL];
		view = view.superview;
	}
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	if ([keyPath isEqualToString:@"superview"]) {
		if ([[change objectForKey:NSKeyValueChangeNotificationIsPriorKey] boolValue]) {
			[self removeHierarchyObservers];
		} else {
			[self buildHierarchyObserversForSuperview:containerView.superview];
		}
		[self updateFrame];
	} else if ([keyPath isEqualToString:@"frame"]) {
		CGRect oldFrame = [[change objectForKey:NSKeyValueChangeOldKey] CGRectValue];
		CGRect newFrame = [[change objectForKey:NSKeyValueChangeNewKey] CGRectValue];
		if (!CGPointEqualToPoint(oldFrame.origin,newFrame.origin)) {
			[self updateFrame];
		}
	}
}

- (void)containerViewWillMoveToSuperview:(UIView *)view
{
	if (editor) {
		[self removeHierarchyObservers];
		[self buildHierarchyObserversForSuperview:view];
	}
}

- (void)containerViewDidMoveToSuperview
{
	[self updateFrame];
}

- (id)mouseCursorForEvent:(UIEvent *)event
{
	return [NSCursor IBeamCursor];
}

- (void)drawText
{
	// don't draw the text or anything if there's an editor over the top of us since it won't show up anyway.
	if (!editor) {
		// this should be the view's desired text bounding box (in the view's coordinate space)
		CGRect rect = containerView.bounds;

		// now draw it
		NSRange range = [layoutManager glyphRangeForBoundingRect:NSRectFromCGRect(rect) inTextContainer:textContainer];
		[layoutManager drawGlyphsForGlyphRange:range atPoint:NSPointFromCGPoint(rect.origin)];
	}
}

- (BOOL)containerViewCanBecomeFirstResponder
{
	return !editor && ([containerView window] != nil);
}

- (void)containerViewDidBecomeFirstResponder
{
	if ([self containerViewCanBecomeFirstResponder]) {
		NSRect frame = [self NSViewFrame];
		
		UICustomNSTextView *textView = [[[UICustomNSTextView alloc] initWithFrame:NSMakeRect(0,0,frame.size.width,frame.size.height) textContainer:textContainer secureTextEntry:secureTextEntry] autorelease];
		[textView setDefaultParagraphStyle:[self paragraphStyle]];
		[textView setEditable:editable];
		[textView setFont:[font _NSFont]];
		[textView setTextColor:[textColor _NSColor]];
		
		editor = [[NSClipView alloc] initWithFrame:frame];
		[editor setDrawsBackground:NO];
		[editor setDocumentView:textView];

		// now that there's an editor, we need to redraw so it won't draw the text twice (once in the UIView and once in the NSView)
		[containerView setNeedsDisplay];

		// and now we need to track the movements of the views all the way down to the window so we can position the NSView correcly. meh..
		[self buildHierarchyObserversForSuperview:containerView.superview];

		// now add the NSView to the real NSWindow and make it the real first responder...
		[[containerView.window.screen _NSView] addSubview:editor];
		[(NSWindow *)[editor window] makeFirstResponder:[editor documentView]];
		
		// and finally, we fake a mouseDown: event if the current event WAS a mouseDown-ish event so that this feels like a real OSX app :)
		NSEvent *currentEvent = [NSApp currentEvent];
		switch ([currentEvent type]) {
			case NSLeftMouseDown:
				[textView mouseDown:currentEvent];
				break;
				
			case NSRightMouseDown:
				[textView rightMouseDown:currentEvent];
				break;
				
			case NSOtherMouseDown:
				[textView otherMouseDown:currentEvent];
				break;
		}
	}
}

- (BOOL)containerViewCanResignFirstResponder
{
	return editor && ([(NSWindow *)[editor window] firstResponder] == [editor documentView]);
}

- (void)containerViewDidResignFirstResponder
{
	if ([self containerViewCanResignFirstResponder]) {
		[(NSWindow *)[editor window] makeFirstResponder:nil];

		[textContainer setTextView:nil];
		[editor removeFromSuperview];
		[editor release];
		editor = nil;
		
		[self removeHierarchyObservers];
		[self updateFrame];
	}
}

- (void)dealloc
{
	// meh
	[self removeHierarchyObservers];	
	[editor removeFromSuperview]; 

	[editor release];

	[textContainer release];
	[layoutManager release];
	[textStorage release];
	
	[textColor release];
	[font release];
	[super dealloc];
}

@end
