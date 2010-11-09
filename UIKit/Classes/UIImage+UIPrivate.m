//  Created by Sean Heber on 11/9/10.
#import "UIImage+UIPrivate.h"
#import <Foundation/Foundation.h>

NSMutableDictionary *imageCache = nil;

@implementation UIImage (UIPrivate)

+ (void)load
{
	imageCache = [[NSMutableDictionary alloc] init];
}

+ (void)_cacheImage:(UIImage *)image forName:(NSString *)name
{
	if (image && name) {
		[imageCache setObject:image forKey:name];
	}
}

+ (UIImage *)_cachedImageForName:(NSString *)name
{
	return [imageCache objectForKey:name];
}

+ (UIImage *)_frameworkImageWithName:(NSString *)name leftCapWidth:(NSUInteger)leftCapWidth topCapHeight:(NSUInteger)topCapHeight
{
	UIImage *image = [self _cachedImageForName:name];

	if (!image) {
		NSBundle *frameworkBundle = [NSBundle bundleWithIdentifier:@"com.iconfactory.UIKit"];
		NSString *frameworkFile = [[frameworkBundle resourcePath] stringByAppendingPathComponent:name];
		image = [[self imageWithContentsOfFile:frameworkFile] stretchableImageWithLeftCapWidth:leftCapWidth topCapHeight:topCapHeight];
		[self _cacheImage:image forName:name];
	}

	return image;
}

+ (UIImage *)_backButtonImage
{
	return [self _frameworkImageWithName:@"<UINavigationBar> back.png" leftCapWidth:18 topCapHeight:0];
}

+ (UIImage *)_highlightedBackButtonImage
{
	return [self _frameworkImageWithName:@"<UINavigationBar> back-highlighted.png" leftCapWidth:18 topCapHeight:0];
}

+ (UIImage *)_toolbarButtonImage
{
	return [self _frameworkImageWithName:@"<UIToolbar> button.png" leftCapWidth:6 topCapHeight:0];
}

+ (UIImage *)_highlightedToolbarButtonImage
{
	return [self _frameworkImageWithName:@"<UIToolbar> button-highlighted.png" leftCapWidth:6 topCapHeight:0];
}

+ (UIImage *)_leftPopoverArrowImage
{
	return [self _frameworkImageWithName:@"<UIPopoverView> arrow-left.png" leftCapWidth:0 topCapHeight:0];
}

+ (UIImage *)_rightPopoverArrowImage
{
	return [self _frameworkImageWithName:@"<UIPopoverView> arrow-right.png" leftCapWidth:0 topCapHeight:0];
}

+ (UIImage *)_topPopoverArrowImage
{
	return [self _frameworkImageWithName:@"<UIPopoverView> arrow-top.png" leftCapWidth:0 topCapHeight:0];
}

+ (UIImage *)_bottomPopoverArrowImage
{
	return [self _frameworkImageWithName:@"<UIPopoverView> arrow-bottom.png" leftCapWidth:0 topCapHeight:0];
}

+ (UIImage *)_popoverBackgroundImage
{
	return [self _frameworkImageWithName:@"<UIPopoverView> background.png" leftCapWidth:23 topCapHeight:23];
}

+ (UIImage *)_roundedRectButtonImage
{
	return [self _frameworkImageWithName:@"<UIRoundedRectButton> normal.png" leftCapWidth:12 topCapHeight:9];
}

+ (UIImage *)_highlightedRoundedRectButtonImage
{
	return [self _frameworkImageWithName:@"<UIRoundedRectButton> highlighted.png" leftCapWidth:12 topCapHeight:9];
}

+ (UIImage *)_windowResizeGrabberImage
{
	return [self _frameworkImageWithName:@"<UIScreen> grabber.png" leftCapWidth:0 topCapHeight:0];
}

+ (UIImage *)_buttonBarSystemItemAdd
{
	return [self _frameworkImageWithName:@"<UIBarButtonSystemItem> add.png" leftCapWidth:0 topCapHeight:0];
}

+ (UIImage *)_buttonBarSystemItemReply
{
	return [self _frameworkImageWithName:@"<UIBarButtonSystemItem> reply.png" leftCapWidth:0 topCapHeight:0];
}

- (UIImage *)_toolbarImage
{
	return self;
}

@end
