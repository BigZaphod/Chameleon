//  Created by Sean Heber on 6/25/10.
#import "UIControl.h"
#import "UITextInputTraits.h"

extern NSString *const UITextFieldTextDidBeginEditingNotification;
extern NSString *const UITextFieldTextDidChangeNotification;
extern NSString *const UITextFieldTextDidEndEditingNotification;

typedef enum {
	UITextBorderStyleNone,
	UITextBorderStyleLine,
	UITextBorderStyleBezel,
	UITextBorderStyleRoundedRect
} UITextBorderStyle;

typedef enum {
	UITextFieldViewModeNever,
	UITextFieldViewModeWhileEditing,
	UITextFieldViewModeUnlessEditing,
	UITextFieldViewModeAlways
} UITextFieldViewMode;

@class UIFont, UIColor, UITextField, UIImage, UITextLayer;

@protocol UITextFieldDelegate <NSObject>
@optional
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField;
- (void)textFieldDidBeginEditing:(UITextField *)textField;
- (BOOL)textFieldShouldEndEditing:(UITextField *)textField;
- (void)textFieldDidEndEditing:(UITextField *)textField;

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string;
- (BOOL)textFieldShouldClear:(UITextField *)textField;
- (BOOL)textFieldShouldReturn:(UITextField *)textField;
@end

@interface UITextField : UIControl <UITextInputTraits> {
@private
	UITextLayer *_textLayer;

	id _delegate;
	UITextFieldViewMode _clearButtonMode;
	UIView *_leftView;
	UITextFieldViewMode _leftViewMode;
	UIView *_rightView;
	UITextFieldViewMode _rightViewMode;
	UIImage *_background;
	UIImage *_disabledBackground;
	
	struct {
		unsigned int shouldBeginEditing : 1;
		unsigned int didBeginEditing : 1;
		unsigned int shouldEndEditing : 1;
		unsigned int didEndEditing : 1;
		unsigned int shouldChangeCharacters : 1;
		unsigned int shouldClear : 1;
		unsigned int shouldReturn : 1;
	} _delegateHas;	
}

- (CGRect)clearButtonRectForBounds:(CGRect)bounds;

@property (nonatomic, assign) id<UITextFieldDelegate> delegate;
@property (nonatomic, copy) NSString *placeholder;
@property (nonatomic, copy) NSString *text;
@property (nonatomic, retain) UIFont *font;
@property (nonatomic) UITextBorderStyle borderStyle;
@property (nonatomic, retain) UIColor *textColor;

@property (nonatomic, retain) UIImage *background;
@property (nonatomic, retain) UIImage *disabledBackground;

@property (nonatomic) UITextFieldViewMode clearButtonMode;
@property (nonatomic, retain) UIView *leftView;
@property (nonatomic) UITextFieldViewMode leftViewMode;
@property (nonatomic, retain) UIView *rightView;
@property (nonatomic) UITextFieldViewMode rightViewMode;

@end
