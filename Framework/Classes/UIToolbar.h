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
}

@property (nonatomic) UIBarStyle barStyle;
@property (nonatomic, retain) UIColor *tintColor;

@end
