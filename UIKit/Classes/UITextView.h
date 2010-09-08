//  Created by Sean Heber on 6/29/10.
#import "UIScrollView.h"
#import "UIDataDetectors.h"
#import "UITextInputTraits.h"

extern NSString *const UITextViewTextDidBeginEditingNotification;
extern NSString *const UITextViewTextDidChangeNotification;
extern NSString *const UITextViewTextDidEndEditingNotification;

@class UIColor, UIFont, UITextLayer, UITextView;

@protocol UITextViewDelegate <NSObject, UIScrollViewDelegate>
@optional
- (BOOL)textViewShouldBeginEditing:(UITextView *)textView;
- (void)textViewDidBeginEditing:(UITextView *)textView;
- (BOOL)textViewShouldEndEditing:(UITextView *)textView;
- (void)textViewDidEndEditing:(UITextView *)textView;
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text;
- (void)textViewDidChange:(UITextView *)textView;
- (void)textViewDidChangeSelection:(UITextView *)textView;
@end

@interface UITextView : UIScrollView <UITextInputTraits> {
@private
	UITextLayer *_textLayer;
	UIDataDetectorTypes _dataDetectorTypes;
	
	struct {
		BOOL shouldBeginEditing : 1;
		BOOL didBeginEditing : 1;
		BOOL shouldEndEditing : 1;
		BOOL didEndEditing : 1;
		BOOL shouldChangeText : 1;
		BOOL didChange : 1;
		BOOL didChangeSelection : 1;
	} _delegateHas;
}

- (void)scrollRangeToVisible:(NSRange)range;

@property (nonatomic) NSRange selectedRange;
@property (nonatomic, getter=isEditable) BOOL editable;
@property (nonatomic, copy) NSString *text;
@property (nonatomic, retain) UIColor *textColor;
@property (nonatomic, retain) UIFont *font;
@property (nonatomic) UIDataDetectorTypes dataDetectorTypes;
@property (nonatomic, assign) id<UITextViewDelegate> delegate;

@end
