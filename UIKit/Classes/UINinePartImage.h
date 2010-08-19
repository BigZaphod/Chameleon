//  Created by Sean Heber on 5/28/10.
#import "UIImage+UIPrivate.h"

@interface UINinePartImage : UIImage {
@private
	id _topLeftCorner;
	id _topEdgeFill;
	id _topRightCorner;
	id _leftEdgeFill;
	id _centerFill;
	id _rightEdgeFill;
	id _bottomLeftCorner;
	id _bottomEdgeFill;
	id _bottomRightCorner;
}

- (id)initWithNSImage:(id)theImage leftCapWidth:(NSInteger)leftCapWidth topCapHeight:(NSInteger)topCapHeight;

@end
