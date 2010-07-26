//  Created by Sean Heber on 6/25/10.
#import "UIView.h"

typedef enum {
	UIActivityIndicatorViewStyleWhiteLarge,
	UIActivityIndicatorViewStyleWhite,
	UIActivityIndicatorViewStyleGray,
} UIActivityIndicatorViewStyle;

@interface UIActivityIndicatorView : UIView {
@private
	BOOL _hidesWhenStopped;
}

- (id)initWithActivityIndicatorStyle:(UIActivityIndicatorViewStyle)style;
- (void)startAnimating;
- (void)stopAnimating;

@property BOOL hidesWhenStopped;

@end
