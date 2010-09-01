//  Created by Sean Heber on 6/25/10.
#import "UIAlertView.h"

#import <AppKit/NSAlert.h>
#import <AppKit/NSPanel.h>

@interface UIAlertView ()
@property (nonatomic, retain) NSMutableArray *buttonTitles;
@end

@implementation UIAlertView
@synthesize title=_title, message=_message, delegate=_delegate, cancelButtonIndex=_cancelButtonIndex, buttonTitles=_buttonTitles;

- (id)initWithTitle:(NSString *)title message:(NSString *)message delegate:(id)delegate cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSString *)otherButtonTitles, ...
{
	if ((self=[super initWithFrame:CGRectZero])) {
		self.title = title;
		self.message = message;
		self.delegate = delegate;
		self.buttonTitles = [NSMutableArray arrayWithCapacity:1];

		if (cancelButtonTitle) {
			self.cancelButtonIndex = [self addButtonWithTitle:cancelButtonTitle];
		}
		
		if (otherButtonTitles) {
			[self addButtonWithTitle:otherButtonTitles];

			id buttonTitle = nil;
			va_list argumentList;
			va_start(argumentList, otherButtonTitles);

			while ((buttonTitle=va_arg(argumentList, NSString *))) {
				
				[self addButtonWithTitle:buttonTitle];
			}
			
			va_end(argumentList);
		}
	}
	return self;
}

- (void)dealloc
{
	self.title = nil;
	self.message = nil;
	self.buttonTitles = nil;

	[super dealloc];
}

- (NSInteger)addButtonWithTitle:(NSString *)title
{
	[self.buttonTitles addObject:title];
	return ([self.buttonTitles count] - 1);
}

- (NSString *)buttonTitleAtIndex:(NSInteger)buttonIndex
{
	return [self.buttonTitles objectAtIndex:buttonIndex];
}


- (NSInteger)numberOfButtons
{
	return [self.buttonTitles count];
}

- (void)show
{
	if (self.delegate && [self.delegate respondsToSelector:@selector(willPresentAlertView:)]) {
		[self.delegate willPresentAlertView:self];
	}
	if (self.delegate && [self.delegate respondsToSelector:@selector(didPresentAlertView:)]) {
		[self.delegate didPresentAlertView:self];
	}

	NSString *defaultButton = nil;
	NSString *alternateButton = nil;
	NSString *otherButton = nil;
	
	NSMutableArray *otherButtonTitles = nil;
	if ([self numberOfButtons] > 0) {
		otherButtonTitles = [self.buttonTitles mutableCopy];
		
		if (self.cancelButtonIndex >= 0) {
			defaultButton = [otherButtonTitles objectAtIndex:self.cancelButtonIndex];
			[otherButtonTitles removeObjectAtIndex:self.cancelButtonIndex];
		}
		
		if ([otherButtonTitles count] >= 1) {
			alternateButton = [otherButtonTitles objectAtIndex:0];
		}
		if ([otherButtonTitles count] >= 2) {
			otherButton = [otherButtonTitles objectAtIndex:1];
		}

		[otherButtonTitles release];
	}

	NSAlert *alert = [[[NSAlert alloc] init] autorelease];

	if (self.title) [alert setMessageText:self.title];
	if (self.message) [alert setInformativeText:self.message];
	if (alternateButton) [alert addButtonWithTitle:alternateButton];
	if (otherButton) [alert addButtonWithTitle:otherButton];
	if (defaultButton) [alert addButtonWithTitle:defaultButton];
	
	NSInteger result = [alert runModal];

	NSInteger buttonIndex = -1;

	switch (result) {
		default:
		case NSAlertFirstButtonReturn:
			buttonIndex = [self.buttonTitles indexOfObject:defaultButton];
			break;
		case NSAlertSecondButtonReturn:
			buttonIndex = [self.buttonTitles indexOfObject:alternateButton];
			break;
		case NSAlertThirdButtonReturn:
			buttonIndex = [self.buttonTitles indexOfObject:otherButton];
			break;
	}

	if (self.delegate && [self.delegate respondsToSelector:@selector(alertView:clickedButtonAtIndex:)]) {
		[self.delegate alertView:self clickedButtonAtIndex:buttonIndex];
	}

	if (self.delegate && [self.delegate respondsToSelector:@selector(alertView:willDismissWithButtonIndex:)]) {
		[self.delegate alertView:self willDismissWithButtonIndex:buttonIndex];
	}
	if (self.delegate && [self.delegate respondsToSelector:@selector(alertView:didDismissWithButtonIndex:)]) {
		[self.delegate alertView:self didDismissWithButtonIndex:buttonIndex];
	}
}

@end
