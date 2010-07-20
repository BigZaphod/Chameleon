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

@class UIFont, UIColor, NSTextField, UITextField;

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
}

@property (nonatomic, assign) id<UITextFieldDelegate> delegate;
@property (nonatomic, copy) NSString *placeholder;
@property (nonatomic, copy) NSString *text;
@property (nonatomic, retain) UIFont *font;
@property (nonatomic) UITextBorderStyle borderStyle;
@property (nonatomic, retain) UIColor *textColor;
@property (nonatomic) UITextFieldViewMode clearButtonMode;

@end
