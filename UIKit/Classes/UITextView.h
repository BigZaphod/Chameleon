//  Created by Sean Heber on 6/29/10.
#import "UIScrollView.h"
#import "UIDataDetectors.h"
#import "UITextInputTraits.h"

@protocol UITextViewDelegate <NSObject, UIScrollViewDelegate>
@end

@class UIColor, UIFont, UITextLayer;

@interface UITextView : UIScrollView <UITextInputTraits> {
@private
	UITextLayer *_textLayer;
	UIDataDetectorTypes _dataDetectorTypes;
}

@property (nonatomic, getter=isEditable) BOOL editable;
@property (nonatomic, copy) NSString *text;
@property (nonatomic, retain) UIColor *textColor;
@property (nonatomic, retain) UIFont *font;
@property (nonatomic) UIDataDetectorTypes dataDetectorTypes;
@property (nonatomic, assign) id<UITextViewDelegate> delegate;

@end
