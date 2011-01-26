//  Created by Sean Heber on 6/25/10.
#import "UIView.h"

@protocol UIAlertViewDelegate;

@interface UIAlertView : UIView {
@private
	NSString *_title;
	NSString *_message;
	id<UIAlertViewDelegate> _delegate;
	NSInteger _cancelButtonIndex;
	NSMutableArray *_buttonTitles;
	
	struct {
		BOOL clickedButtonAtIndex : 1;
		BOOL alertViewCancel : 1;
		BOOL willPresentAlertView : 1;
		BOOL didPresentAlertView : 1;
		BOOL willDismissWithButtonIndex : 1;
		BOOL didDismissWithButtonIndex : 1;
	} _delegateHas;
}

- (id)initWithTitle:(NSString *)title message:(NSString *)message delegate:(id)delegate cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSString *)otherButtonTitles, ...;

- (NSInteger)addButtonWithTitle:(NSString *)title;
- (NSString *)buttonTitleAtIndex:(NSInteger)buttonIndex;
- (void)show;
- (void)dismissWithClickedButtonIndex:(NSInteger)buttonIndex animated:(BOOL)animated;		// not implemented at the moment since I use NSAlert and runModal and this would present problems. :/

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *message;
@property (nonatomic, assign) id<UIAlertViewDelegate> delegate;
@property (nonatomic) NSInteger cancelButtonIndex;
@property (nonatomic,readonly) NSInteger numberOfButtons;

@end

@protocol UIAlertViewDelegate <NSObject>
@optional

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;

- (void)alertViewCancel:(UIAlertView *)alertView; // never called

- (void)willPresentAlertView:(UIAlertView *)alertView;  // before animation and showing view
- (void)didPresentAlertView:(UIAlertView *)alertView;  // after animation

- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex; // before animation and hiding view
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex;  // after animation

@end
