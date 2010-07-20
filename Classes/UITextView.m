//  Created by Sean Heber on 6/29/10.
#import "UITextView.h"
#import "UIFont.h"
#import "UIColor.h"

@implementation UITextView
@synthesize text=_text, textColor=_textColor, font=_font, dataDetectorTypes=_dataDetectorTypes, editable=_editable;
@dynamic delegate;

- (id)initWithFrame:(CGRect)frame
{
	if ((self=[super initWithFrame:frame])) {
		self.textColor = [UIColor blackColor];
		self.font = [UIFont systemFontOfSize:17];
		self.dataDetectorTypes = UIDataDetectorTypeAll;
		self.editable = YES;
	}
	return self;
}

- (void)dealloc
{
	[_text release];
	[_textColor release];
	[_font release];
	[super dealloc];
}

- (UITextAutocapitalizationType)autocapitalizationType
{
	return UITextAutocapitalizationTypeNone;
}

- (void)setAutocapitalizationType:(UITextAutocapitalizationType)type
{
}

- (UITextAutocorrectionType)autocorrectionType
{
	return UITextAutocorrectionTypeDefault;
}

- (void)setAutocorrectionType:(UITextAutocorrectionType)type
{
}

- (BOOL)enablesReturnKeyAutomatically
{
	return YES;
}

- (void)setEnablesReturnKeyAutomatically:(BOOL)enabled
{
}

- (UIKeyboardAppearance)keyboardAppearance
{
	return UIKeyboardAppearanceDefault;
}

- (void)setKeyboardAppearance:(UIKeyboardAppearance)type
{
}

- (UIKeyboardType)keyboardType
{
	return UIKeyboardTypeDefault;
}

- (void)setKeyboardType:(UIKeyboardType)type
{
}

- (UIReturnKeyType)returnKeyType
{
	return UIReturnKeyDefault;
}

- (void)setReturnKeyType:(UIReturnKeyType)type
{
}

- (BOOL)isSecureTextEntry
{
	return NO;
}

- (void)setSecureTextEntry:(BOOL)secure
{
}

@end
