//  Created by Sean Heber on 8/26/10.
#import <QuartzCore/CALayer.h>

@class UICustomNSClipView, UICustomNSTextView, UIColor, UIFont, UIScrollView, UIWindow, UIView;

@protocol UITextLayerContainerViewProtocol <NSObject>
@required
- (UIWindow *)window;
- (CALayer *)layer;
- (BOOL)isHidden;
- (BOOL)isDescendantOfView:(UIView *)view;

// if any one of these doesn't exist, then scrolling of the NSClipView is disabled
@optional
- (BOOL)isScrollEnabled;
- (void)setContentOffset:(CGPoint)offset;
- (CGPoint)contentOffset;
- (void)setContentSize:(CGSize)size;
- (CGSize)contentSize;
@end

@protocol UITextLayerTextDelegate <NSObject>
@required
- (BOOL)_textShouldBeginEditing;
- (void)_textDidBeginEditing;
- (BOOL)_textShouldEndEditing;
- (void)_textDidEndEditing;
- (BOOL)_textShouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text;

@optional
- (void)_textDidChange;
- (void)_textDidChangeSelection;
@end

@interface UITextLayer : CALayer {
	id<UITextLayerContainerViewProtocol> containerView;
	id<UITextLayerTextDelegate> textDelegate;
	BOOL containerCanScroll;
	UICustomNSTextView *textView;
	UICustomNSClipView *clipView;
	BOOL secureTextEntry;
	BOOL editable;
	UIColor *textColor;
	UIFont *font;
	
	struct {
		unsigned int didChange : 1;
		unsigned int didChangeSelection : 1;
	} textDelegateHas;
}

- (id)initWithContainerView:(id<UITextLayerContainerViewProtocol>)aView textDelegate:(id<UITextLayerTextDelegate>)aDelegate;
- (void)setContentOffset:(CGPoint)contentOffset;

@property (nonatomic, copy) NSString *text;
@property (nonatomic, retain) UIColor *textColor;
@property (nonatomic, retain) UIFont *font;
@property (nonatomic, assign) BOOL editable;
@property (nonatomic, getter=isSecureTextEntry) BOOL secureTextEntry;

@end
