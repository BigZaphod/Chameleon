//  Created by Sean Heber on 6/25/10.
#import "UIView.h"

@protocol UIActionSheetDelegate <NSObject>
@end

@interface UIActionSheet : UIView {
@private
	id _delegate;
	NSInteger _destructiveButtonIndex;
	BOOL _visible;
	NSInteger _cancelButtonIndex;
	NSString *_title;
}

- (id)initWithTitle:(NSString *)title delegate:(id < UIActionSheetDelegate >)delegate cancelButtonTitle:(NSString *)cancelButtonTitle destructiveButtonTitle:(NSString *)destructiveButtonTitle otherButtonTitles:(NSString *)otherButtonTitles, ...;
- (NSInteger)addButtonWithTitle:(NSString *)title;

- (void)showInView:(UIView *)view;
- (void)showFromRect:(CGRect)rect inView:(UIView *)view animated:(BOOL)animated;
- (void)dismissWithClickedButtonIndex:(NSInteger)buttonIndex animated:(BOOL)animated;

@property (nonatomic, copy) NSString *title;
@property (nonatomic, assign) id<UIActionSheetDelegate> delegate;
@property (nonatomic, readonly, getter=isVisible) BOOL visible;
@property (nonatomic) NSInteger destructiveButtonIndex;
@property (nonatomic) NSInteger cancelButtonIndex;

@end
