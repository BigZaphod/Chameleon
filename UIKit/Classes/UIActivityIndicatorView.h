//  Created by Sean Heber on 6/25/10.
#import "UIView.h"

typedef enum {
	UIActivityIndicatorViewStyleWhiteLarge,
	UIActivityIndicatorViewStyleWhite,
	UIActivityIndicatorViewStyleGray,
} UIActivityIndicatorViewStyle;

@interface UIActivityIndicatorView : UIView {
@private
	UIActivityIndicatorViewStyle _activityIndicatorViewStyle;
	BOOL _hidesWhenStopped;
	BOOL _animating;
}

- (id)initWithActivityIndicatorStyle:(UIActivityIndicatorViewStyle)style;
- (void)startAnimating;
- (void)stopAnimating;
- (BOOL)isAnimating;

@property BOOL hidesWhenStopped;
@property UIActivityIndicatorViewStyle activityIndicatorViewStyle;

@end
