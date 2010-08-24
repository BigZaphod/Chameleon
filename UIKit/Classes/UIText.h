//  Created by Sean Heber on 8/23/10.
#import <Foundation/Foundation.h>

@class UIView, UIColor, UIFont, UIEvent, NSTextStorage, NSLayoutManager, NSTextContainer, NSTextView, UIClipNSView;

@interface UIText : NSObject {
	__weak UIView *containerView;

	NSTextStorage *textStorage;
	NSLayoutManager *layoutManager;
	NSTextContainer *textContainer;
	BOOL needsAttributeUpdate;
	
	//BOOL isFirstResponder;
	
	//UIClipNSView *clipView;
	//NSTextView *textView;
	
	UIColor *textColor;
	UIFont *font;
}

- (id)initWithContainerView:(UIView *)view;
- (void)updateFrame;
- (void)containerViewWillMoveToSuperview:(UIView *)view;
- (void)containerViewDidMoveToSuperview;
- (void)setHidden:(BOOL)hidden;
- (id)mouseCursorForEvent:(UIEvent *)event;
- (void)drawInRect:(CGRect)rect;

- (void)containerViewBecameFirstResponder;
- (void)containerViewResignedFirstResponder;

@property (nonatomic, copy) NSString *text;
@property (nonatomic, retain) UIColor *textColor;
@property (nonatomic, retain) UIFont *font;
@property (nonatomic, assign) BOOL editable;
@end
