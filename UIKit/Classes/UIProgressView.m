//  Created by Sean Heber on 12/16/10.
#import "UIProgressView.h"

@implementation UIProgressView
@synthesize progressViewStyle=_progressViewStyle, progress=_progress;

- (id)initWithProgressViewStyle:(UIProgressViewStyle)style
{
	if ((self=[super initWithFrame:CGRectMake(0,0,0,0)])) {
		_progressViewStyle = style;
	}
	return self;
}

- (void)setProgressViewStyle:(UIProgressViewStyle)style
{
	if (style != _progressViewStyle) {
		_progressViewStyle = style;
		[self setNeedsDisplay];
	}
}

- (void)setProgress:(float)p
{
	if (p != _progress) {
		_progress = MIN(1,MAX(0,p));
		[self setNeedsDisplay];
	}
}

@end
