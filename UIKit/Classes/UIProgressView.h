//  Created by Sean Heber on 12/16/10.
#import "UIView.h"

typedef enum {
	UIProgressViewStyleDefault,
	UIProgressViewStyleBar,
} UIProgressViewStyle;

@interface UIProgressView : UIView {
	UIProgressViewStyle _progressViewStyle;
	float _progress;
}

- (id)initWithProgressViewStyle:(UIProgressViewStyle)style;

@property (nonatomic) UIProgressViewStyle progressViewStyle;
@property (nonatomic) float progress;

@end
