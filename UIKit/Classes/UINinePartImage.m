//  Created by Sean Heber on 5/28/10.
#import "UINinePartImage.h"
#import "AppKitIntegration.h"
#import "UIGraphics.h"
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

- (void)drawInRect:(CGRect)rect
{
	// There aren't enough NSCompositingOperations to map all possible CGBlendModes, so rather than have gaps in the support,
	// I am drawing the multipart image into a new image context which is then drawn in the usual way which results in the draw
	// obeying the currently active CGBlendMode and doing the expected thing. This is no doubt more expensive than it could be,
	// but I suspect it's pretty irrelevant in the grand scheme of things.
	UIGraphicsBeginImageContext(rect.size);
	NSDrawNinePartImage(NSMakeRect(0,0,rect.size.width,rect.size.height), _topLeftCorner, _topEdgeFill, _topRightCorner, _leftEdgeFill, _centerFill, _rightEdgeFill, _bottomLeftCorner, _bottomEdgeFill, _bottomRightCorner, NSCompositeCopy, 1, YES);
	UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	[img drawInRect:rect];
	
}

@end
