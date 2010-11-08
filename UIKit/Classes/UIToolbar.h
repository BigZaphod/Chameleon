//  Created by Sean Heber on 6/25/10.
#import "UIView.h"

typedef enum {
	UIBarStyleDefault          = 0,
	UIBarStyleBlack            = 1,
	
	UIBarStyleBlackOpaque      = 1, // Deprecated
	UIBarStyleBlackTranslucent = 2, // Deprecated
} UIBarStyle;

@interface UIToolbar : UIView {
@private
	UIBarStyle _barStyle;
	UIColor *_tintColor;
	NSMutableArray *_toolbarItems;
	BOOL _translucent;
}

- (void)setItems:(NSArray *)items animated:(BOOL)animated;

@property (nonatomic) UIBarStyle barStyle;
@property (nonatomic, retain) UIColor *tintColor;
@property (nonatomic, copy) NSArray *items;
@property (nonatomic,assign,getter=isTranslucent) BOOL translucent;

@end
