//  Created by Sean Heber on 5/28/10.
#import "UIImage.h"

@interface _UIThreePartImage : UIImage {
@private
	id _startCap;
	id _centerFill;
	id _endCap;
	BOOL _vertical;
}

- (id)initWithNSImage:(id)theImage capSize:(NSInteger)capSize vertical:(BOOL)isVertical;

@end
