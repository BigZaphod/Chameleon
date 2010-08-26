//  Created by Sean Heber on 8/23/10.
#import <Foundation/Foundation.h>

@class UIWindow, UIView, UIColor, UIFont, UIEvent, NSTextStorage, NSLayoutManager, NSTextContainer;

@protocol UITextContainerViewProtocol <NSObject>
- (void)setNeedsDisplay;
- (UIWindow *)window;
- (CGRect)frame;
- (CGRect)bounds;
- (UIView *)superview;
@end

@interface UIText : NSObject {
	__weak id<UITextContainerViewProtocol> containerView;

	NSTextStorage *textStorage;
	NSLayoutManager *layoutManager;
	NSTextContainer *textContainer;
	BOOL secureTextEntry;
	BOOL editable;
	id editor;
	UIColor *textColor;
	UIFont *font;
}

- (id)initWithContainerView:(id<UITextContainerViewProtocol>)view;

- (void)containerViewFrameDidChange;
- (void)containerViewWillMoveToSuperview:(UIView *)view;
- (void)containerViewDidMoveToSuperview;
- (void)setHidden:(BOOL)hidden;
- (id)mouseCursorForEvent:(UIEvent *)event;
- (void)drawText;

- (BOOL)containerViewCanBecomeFirstResponder;
- (void)containerViewDidBecomeFirstResponder;
- (BOOL)containerViewCanResignFirstResponder;
- (void)containerViewDidResignFirstResponder;

@property (nonatomic, copy) NSString *text;
@property (nonatomic, retain) UIColor *textColor;
@property (nonatomic, retain) UIFont *font;
@property (nonatomic, assign) BOOL editable;
@property (nonatomic, getter=isSecureTextEntry) BOOL secureTextEntry;
@end
