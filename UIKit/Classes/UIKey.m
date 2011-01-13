//  Created by Sean Heber on 1/13/11.
#import "UIKey+UIPrivate.h"
#import <AppKit/NSEvent.h>

@implementation UIKey
@synthesize keyCode=_keyCode, characters=_characters, charactersWithModifiers=_charactersWithModifiers, repeat=_repeat;

- (id)initWithNSEvent:(NSEvent *)event
{
	if ((self=[super init])) {
		_keyCode = [event keyCode];
		_characters = [[event charactersIgnoringModifiers] copy];
		_charactersWithModifiers = [[event characters] copy];
		_repeat = [event isARepeat];
		_modifierFlags = [event modifierFlags];
	}
	return self;
}

- (UIKeyType)type
{
	if ([_characters length] > 0) {
		switch ([_characters characterAtIndex:0]) {
			case NSUpArrowFunctionKey:			return UIKeyTypeUpArrow;
			case NSDownArrowFunctionKey:		return UIKeyTypeDownArrow;
			case NSLeftArrowFunctionKey:		return UIKeyTypeLeftArrow;
			case NSRightArrowFunctionKey:		return UIKeyTypeRightArrow;
			case NSEndFunctionKey:				return UIKeyTypeEnd;
			case NSPageUpFunctionKey:			return UIKeyTypePageUp;
			case NSPageDownFunctionKey:			return UIKeyTypePageDown;
			case NSDeleteFunctionKey:			return UIKeyTypeDelete;
			case NSInsertFunctionKey:			return UIKeyTypeInsert;
			case NSHomeFunctionKey:				return UIKeyTypeHome;
			case 0x000D:						return UIKeyTypeReturn;
			case 0x0003:						return UIKeyTypeEnter;
		}
	}
	
	return UIKeyTypeCharacter;
}

- (BOOL)isCapslockEnabled
{
	return (_modifierFlags & NSAlphaShiftKeyMask) == NSAlphaShiftKeyMask;
}

- (BOOL)isShiftKeyPressed
{
	return (_modifierFlags & NSShiftKeyMask) == NSShiftKeyMask;
}

- (BOOL)isControlKeyPressed
{
	return (_modifierFlags & NSControlKeyMask) == NSControlKeyMask;
}

- (BOOL)isOptionKeyPressed
{
	return (_modifierFlags & NSAlternateKeyMask) == NSAlternateKeyMask;
}

- (BOOL)isCommandKeyPressed
{
	return (_modifierFlags & NSCommandKeyMask) == NSCommandKeyMask;
}

@end
