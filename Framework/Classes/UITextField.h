//  Created by Sean Heber on 6/25/10.
#import "UIControl.h"
#import "UITextInputTraits.h"

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

@class UIFont, UIColor, NSTextField, UITextField, UIImage;

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
	id _delegate;
	UIFont *_font;
	UIColor *_textColor;
	UITextFieldViewMode _clearButtonMode;
	NSTextField *_textField;
	UIView *_leftView;
	UITextFieldViewMode _leftViewMode;
	UIView *_rightView;
	UITextFieldViewMode _rightViewMode;
	UIImage *_background;
	UIImage *_disabledBackground;
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
