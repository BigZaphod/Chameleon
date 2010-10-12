//  Created by Sean Heber on 5/28/10.
#import "UINinePartImage.h"
#import "UIImageTools.h"
#import "UIAppKitIntegration.h"
#import <AppKit/AppKit.h>

@implementation UINinePartImage

- (id)initWithNSImage:(id)theImage leftCapWidth:(NSInteger)leftCapWidth topCapHeight:(NSInteger)topCapHeight
{
	if ((self=[super initWithNSImage:theImage])) {
		const CGSize size = self.size;
		const CGFloat stretchyWidth = (leftCapWidth < size.width)? 1 : 0;
		const CGFloat stretchyHeight = (topCapHeight < size.height)? 1 : 0;
		const CGFloat bottomCapHeight = size.height - topCapHeight - stretchyHeight;
		
		_topLeftCorner = _NSImageCreateSubimage(theImage, CGRectMake(0,0,leftCapWidth,topCapHeight));
		_topEdgeFill = _NSImageCreateSubimage(theImage, CGRectMake(leftCapWidth,0,stretchyWidth,topCapHeight));
		_topRightCorner = _NSImageCreateSubimage(theImage, CGRectMake(leftCapWidth+stretchyWidth,0,size.width-leftCapWidth-stretchyWidth,topCapHeight));
		
		_bottomLeftCorner = _NSImageCreateSubimage(theImage, CGRectMake(0,size.height-bottomCapHeight,leftCapWidth,bottomCapHeight));
		_bottomEdgeFill = _NSImageCreateSubimage(theImage, CGRectMake(leftCapWidth,size.height-bottomCapHeight,stretchyWidth,bottomCapHeight));
		_bottomRightCorner = _NSImageCreateSubimage(theImage, CGRectMake(leftCapWidth+stretchyWidth,size.height-bottomCapHeight,size.width-leftCapWidth-stretchyWidth,bottomCapHeight));

		_leftEdgeFill = _NSImageCreateSubimage(theImage, CGRectMake(0,topCapHeight,leftCapWidth,stretchyHeight));
		_centerFill = _NSImageCreateSubimage(theImage, CGRectMake(leftCapWidth,topCapHeight,stretchyWidth,stretchyHeight));
		_rightEdgeFill = _NSImageCreateSubimage(theImage, CGRectMake(leftCapWidth+stretchyWidth,topCapHeight,size.width-leftCapWidth-stretchyWidth,stretchyHeight));
	}
	return self;
}

- (void)dealloc
{
	[_topLeftCorner release];
	[_topEdgeFill release];
	[_topRightCorner release];
	[_leftEdgeFill release];
	[_centerFill release];
	[_rightEdgeFill release];
	[_bottomLeftCorner release];
	[_bottomEdgeFill release];
	[_bottomRightCorner release];
	[super dealloc];
}

- (NSInteger)leftCapWidth
{
	return [_topLeftCorner size].width;
}

- (NSInteger)topCapHeight
{
	return [_topLeftCorner size].height;
}

- (void)drawInRect:(CGRect)rect blendMode:(CGBlendMode)blendMode alpha:(CGFloat)alpha
{
	NSDrawNinePartImage(NSRectFromCGRect(rect), _topLeftCorner, _topEdgeFill, _topRightCorner, _leftEdgeFill, _centerFill, _rightEdgeFill, _bottomLeftCorner, _bottomEdgeFill, _bottomRightCorner, _NSCompositingOperationFromCGBlendMode(blendMode), alpha, YES);
}

@end
