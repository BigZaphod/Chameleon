//  Created by Sean Heber on 6/25/10.
#import <Foundation/Foundation.h>

typedef enum {
	UITextAutocapitalizationTypeNone,
	UITextAutocapitalizationTypeWords,
	UITextAutocapitalizationTypeSentences,
	UITextAutocapitalizationTypeAllCharacters,
} UITextAutocapitalizationType;

typedef enum {
	UITextAutocorrectionTypeDefault,
	UITextAutocorrectionTypeNo,
	UITextAutocorrectionTypeYes,
} UITextAutocorrectionType;

typedef enum {
	UIKeyboardAppearanceDefault,
	UIKeyboardAppearanceAlert,
} UIKeyboardAppearance;

typedef enum {
	UIKeyboardTypeDefault,
	UIKeyboardTypeASCIICapable,
	UIKeyboardTypeNumbersAndPunctuation,
	UIKeyboardTypeURL,
	UIKeyboardTypeNumberPad,
	UIKeyboardTypePhonePad,
	UIKeyboardTypeNamePhonePad,
	UIKeyboardTypeEmailAddress,
	UIKeyboardTypeAlphabet = UIKeyboardTypeASCIICapable
} UIKeyboardType;

typedef enum {
	UIReturnKeyDefault,
	UIReturnKeyGo,
	UIReturnKeyGoogle,
	UIReturnKeyJoin,
	UIReturnKeyNext,
	UIReturnKeyRoute,
	UIReturnKeySearch,
	UIReturnKeySend,
	UIReturnKeyYahoo,
	UIReturnKeyDone,
	UIReturnKeyEmergencyCall,
} UIReturnKeyType;

@protocol UITextInputTraits <NSObject>
@property (nonatomic) UITextAutocapitalizationType autocapitalizationType;
@property (nonatomic) UITextAutocorrectionType autocorrectionType;
@property (nonatomic) BOOL enablesReturnKeyAutomatically;
@property (nonatomic) UIKeyboardAppearance keyboardAppearance;
@property (nonatomic) UIKeyboardType keyboardType;
@property (nonatomic) UIReturnKeyType returnKeyType;
@property (nonatomic, getter=isSecureTextEntry) BOOL secureTextEntry;
@end
