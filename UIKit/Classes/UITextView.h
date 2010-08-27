//  Created by Sean Heber on 6/29/10.
#import "UIScrollView.h"
#import "UIDataDetectors.h"
#import "UITextInputTraits.h"

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
		unsigned int shouldBeginEditing : 1;
		unsigned int didBeginEditing : 1;
		unsigned int shouldEndEditing : 1;
		unsigned int didEndEditing : 1;
		unsigned int shouldChangeText : 1;
		unsigned int didChange : 1;
		unsigned int didChangeSelection : 1;
	} _delegateHas;
}

@property (nonatomic, getter=isEditable) BOOL editable;
@property (nonatomic, copy) NSString *text;
@property (nonatomic, retain) UIColor *textColor;
@property (nonatomic, retain) UIFont *font;
@property (nonatomic) UIDataDetectorTypes dataDetectorTypes;
@property (nonatomic, assign) id<UITextViewDelegate> delegate;

@end
