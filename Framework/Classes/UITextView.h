//  Created by Sean Heber on 6/29/10.
#import "UIScrollView.h"
#import "UIDataDetectors.h"
#import "UITextInputTraits.h"

@protocol UITextViewDelegate <NSObject, UIScrollViewDelegate>
@end

@class UIColor, UIFont;

@interface UITextView : UIScrollView <UITextInputTraits> {
@private
	NSString *_text;
	UIColor *_textColor;
	UIFont *_font;
	UIDataDetectorTypes _dataDetectorTypes;
	BOOL _editable;
}

@property (nonatomic, getter=isEditable) BOOL editable;
@property (nonatomic, copy) NSString *text;
@property (nonatomic, retain) UIColor *textColor;
@property (nonatomic, retain) UIFont *font;
@property (nonatomic) UIDataDetectorTypes dataDetectorTypes;
@property (nonatomic, assign) id<UITextViewDelegate> delegate;

@end
