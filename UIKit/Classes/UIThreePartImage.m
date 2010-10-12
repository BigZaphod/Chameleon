//  Created by Sean Heber on 5/28/10.
#import "UIThreePartImage.h"
#import "UIImageTools.h"
#import "UIAppKitIntegration.h"
#import <AppKit/AppKit.h>

@implementation UIThreePartImage

- (id)initWithNSImage:(id)theImage capSize:(NSInteger)capSize vertical:(BOOL)isVertical
{
	if ((self=[super initWithNSImage:theImage])) {
		const CGSize size = self.size;

		_vertical = isVertical;
		
		if (_vertical) {
			const CGFloat stretchyHeight = (capSize < size.height)? 1 : 0;
			const CGFloat bottomCapHeight = size.height - capSize - stretchyHeight;
			
			_startCap = _NSImageCreateSubimage(theImage, CGRectMake(0,0,size.width,capSize));
			_centerFill = _NSImageCreateSubimage(theImage, CGRectMake(0,capSize,size.width,stretchyHeight));
			_endCap = _NSImageCreateSubimage(theImage, CGRectMake(0,size.height-bottomCapHeight,size.width,bottomCapHeight));
		} else {
			const CGFloat stretchyWidth = (capSize < size.width)? 1 : 0;
			const CGFloat rightCapWidth = size.width - capSize - stretchyWidth;

			_startCap = _NSImageCreateSubimage(theImage, CGRectMake(0,0,capSize,size.height));
			_centerFill = _NSImageCreateSubimage(theImage, CGRectMake(capSize,0,stretchyWidth,size.height));
			_endCap = _NSImageCreateSubimage(theImage, CGRectMake(size.width-rightCapWidth,0,rightCapWidth,size.height));
		}
	}
	return self;
}

- (void)dealloc
{
	[_startCap release];
	[_centerFill release];
	[_endCap release];
	[super dealloc];
}

- (NSInteger)leftCapWidth
{
	return _vertical? 0 : [_startCap size].width;
}

- (NSInteger)topCapHeight
{
	return _vertical? [_startCap size].height : 0;
}

- (void)drawInRect:(CGRect)rect blendMode:(CGBlendMode)blendMode alpha:(CGFloat)alpha
{
	NSDrawThreePartImage(NSRectFromCGRect(rect), _startCap, _centerFill, _endCap, _vertical, _NSCompositingOperationFromCGBlendMode(blendMode), alpha, YES);
}

@end
