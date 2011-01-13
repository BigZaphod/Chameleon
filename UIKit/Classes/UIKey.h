//  Created by Sean Heber on 1/13/11.
#import <Foundation/Foundation.h>

// NOTE: This does not come from Apple's UIKit and only exist to solve some current problems.
// I have no idea what Apple will do with keyboard handling. If they ever expose that stuff publically,
// then all of this should change to reflect the official API.

typedef enum {
	UIKeyTypeCharacter,		// the catch-all/default... I wouldn't depend much on this at this point
	UIKeyTypeUpArrow,
	UIKeyTypeDownArrow,
	UIKeyTypeLeftArrow,
	UIKeyTypeRightArrow,
	UIKeyTypeReturn,
	UIKeyTypeEnter,
	UIKeyTypeHome,
	UIKeyTypeInsert,
	UIKeyTypeDelete,
	UIKeyTypeEnd,
	UIKeyTypePageUp,
	UIKeyTypePageDown,
} UIKeyType;

@interface UIKey : NSObject {
	@public
	unsigned short _keyCode;
	NSString *_characters;
	NSString *_charactersWithModifiers;
	NSUInteger _modifierFlags;
	BOOL _repeat;
}

@property (nonatomic, readonly) UIKeyType type;
@property (nonatomic, readonly) unsigned short keyCode;
@property (nonatomic, readonly) NSString *characters;
@property (nonatomic, readonly) NSString *charactersWithModifiers;
@property (nonatomic, readonly, getter=isRepeat) BOOL repeat;
@property (nonatomic, readonly, getter=isCapslockEnabled) BOOL capslockEnabled;
@property (nonatomic, readonly, getter=isShiftKeyPressed) BOOL shiftKeyPressed;
@property (nonatomic, readonly, getter=isControlKeyPressed) BOOL controlKeyPressed;
@property (nonatomic, readonly, getter=isOptionKeyPressed) BOOL optionKeyPressed;
@property (nonatomic, readonly, getter=isCommandKeyPressed) BOOL commandKeyPressed;

@end
