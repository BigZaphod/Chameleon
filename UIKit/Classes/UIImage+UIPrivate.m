/*
 * Copyright (c) 2011, The Iconfactory. All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 *
 * 2. Redistributions in binary form must reproduce the above copyright notice,
 *    this list of conditions and the following disclaimer in the documentation
 *    and/or other materials provided with the distribution.
 *
 * 3. Neither the name of The Iconfactory nor the names of its contributors may
 *    be used to endorse or promote products derived from this software without
 *    specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE ICONFACTORY BE LIABLE FOR ANY DIRECT,
 * INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
 * BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
 * LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
 * OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
 * ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import "UIImage+UIPrivate.h"
#import "UIImageAppKitIntegration.h"
#import "UIColor.h"
#import "UIGraphics.h"
#import <AppKit/NSImage.h>

NSMutableDictionary *imageCache = nil;

@implementation UIImage (UIPrivate)

+ (void)load
{
    imageCache = [[NSMutableDictionary alloc] init];
}

+ (NSString *)_macPathForFile:(NSString *)path
{
    NSString *home = [path stringByDeletingLastPathComponent];
    NSString *filename = [path lastPathComponent];
    NSString *extension = [filename pathExtension];
    NSString *bareFilename = [filename stringByDeletingPathExtension];

    return [home stringByAppendingPathComponent:[[bareFilename stringByAppendingString:@"@mac"] stringByAppendingPathExtension:extension]];
}

+ (NSString *)_pathForFile:(NSString *)path
{
    NSString *macPath = [self _macPathForFile:path];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:macPath]) {
        return macPath;
    } else {
        return path;
    }
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

+ (NSString *)_nameForCachedImage:(UIImage *)image
{
    __block NSString * result = nil;
    [imageCache enumerateKeysAndObjectsUsingBlock: ^(id key, id obj, BOOL *stop) {
        if ( obj == image ) {
            result = [key copy];
            *stop = YES;
        }
    }];
    return [result autorelease];
}

+ (UIImage *)_imageFromNSImage:(NSImage *)ns
{
    // if the NSImage isn't named, we can't optimize
    if ([[ns name] length] == 0)
        return [[[self alloc] initWithNSImage:ns] autorelease];
    
    // if it's named, we can cache a UIImage instance for it
    UIImage *cached = [self _cachedImageForName:[ns name]];
    if (cached == nil) {
        cached = [[[self alloc] initWithNSImage:ns] autorelease];
        [self _cacheImage:cached forName:[ns name]];
    }
    
    return cached;
}

+ (UIImage *)_frameworkImageWithName:(NSString *)name leftCapWidth:(NSUInteger)leftCapWidth topCapHeight:(NSUInteger)topCapHeight
{
    UIImage *image = [self _cachedImageForName:name];

    if (!image) {
        NSBundle *frameworkBundle = [NSBundle bundleWithIdentifier:@"org.chameleonproject.UIKit"];
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

+ (UIImage *)_textFieldRoundedRectBackground
{
    return [self _frameworkImageWithName:@"<UITextField> roundedRectBackgroundImage.png" leftCapWidth:12.0f topCapHeight:0];
}

+ (UIImage *)_searchBarIcon
{
	return [self _frameworkImageWithName:@"<UISearchBar> search-icon.png" leftCapWidth:0.0f topCapHeight:0.0f];
}

+ (UIImage *)_buttonBarSystemItemCompose
{
    return [self _frameworkImageWithName:@"<UIBarButtonSystemItem> compose.png" leftCapWidth:0 topCapHeight:0];
}

+ (UIImage *)_buttonBarSystemItemAction
{
    return [self _frameworkImageWithName:@"<UIBarButtonSystemItem> action.png" leftCapWidth:0 topCapHeight:0];
}

+ (UIImage *)_buttonBarSystemItemOrganize;
{
    return [self _frameworkImageWithName:@"<UIBarButtonSystemItem> organize.png" leftCapWidth:0 topCapHeight:0];
}

+ (UIImage *)_buttonBarSystemItemTrash;
{
    return [self _frameworkImageWithName:@"<UIBarButtonSystemItem> trash.png" leftCapWidth:0 topCapHeight:0];
}

+ (UIImage *)_buttonBarSystemItemBookmarks;
{
    return [self _frameworkImageWithName:@"<UIBarButtonSystemItem> bookmarks.png" leftCapWidth:0 topCapHeight:0];
}

+ (UIImage *)_buttonBarSystemItemSearch;
{
    return [self _frameworkImageWithName:@"<UIBarButtonSystemItem> search.png" leftCapWidth:0 topCapHeight:0];
}

+ (UIImage *)_buttonBarSystemItemRefresh;
{
    return [self _frameworkImageWithName:@"<UIBarButtonSystemItem> refresh.png" leftCapWidth:0 topCapHeight:0];
}

+ (UIImage *)_buttonBarSystemItemStop;
{
    return [self _frameworkImageWithName:@"<UIBarButtonSystemItem> stop.png" leftCapWidth:0 topCapHeight:0];
}

+ (UIImage *)_buttonBarSystemItemCamera;
{
    return [self _frameworkImageWithName:@"<UIBarButtonSystemItem> camera.png" leftCapWidth:0 topCapHeight:0];
}

+ (UIImage *)_buttonBarSystemItemPlay;
{
    return [self _frameworkImageWithName:@"<UIBarButtonSystemItem> play.png" leftCapWidth:0 topCapHeight:0];
}

+ (UIImage *)_buttonBarSystemItemPause;
{
    return [self _frameworkImageWithName:@"<UIBarButtonSystemItem> search.png" leftCapWidth:0 topCapHeight:0];
}

+ (UIImage *)_buttonBarSystemItemRewind;
{
    return [self _frameworkImageWithName:@"<UIBarButtonSystemItem> rewind.png" leftCapWidth:0 topCapHeight:0];
}

+ (UIImage *)_buttonBarSystemItemFastForward;
{
    return [self _frameworkImageWithName:@"<UIBarButtonSystemItem> fastforward.png" leftCapWidth:0 topCapHeight:0];
}

+ (UIImage *)_buttonBarSystemItemDone
{
	return [self _frameworkImageWithName:@"<UIBarButtonItemStyleDone>.png" leftCapWidth:8 topCapHeight:0];
}

+ (UIImage *)_highlightedButtonBarSystemItemDone
{
	return [self _frameworkImageWithName:@"<UIBarButtonItemStyleDone> hi.png" leftCapWidth:8 topCapHeight:0];
}

+ (UIImage *)_buttonBarSystemItemPlain
{
	return [self _frameworkImageWithName:@"<UIBarButtonItemStylePlain>.png" leftCapWidth:8 topCapHeight:0];
}

+ (UIImage *)_highlightedButtonBarSystemItemPlain
{
	return [self _frameworkImageWithName:@"<UIBarButtonItemStylePlain> hi.png" leftCapWidth:8 topCapHeight:0];
}

+ (UIImage *)_tableSelection
{
	return [self _frameworkImageWithName:@"<UITableView> selection.png" leftCapWidth:0 topCapHeight:0];
}

+ (UIImage *)_tableSelectionGray
{
	return [self _frameworkImageWithName:@"<UITableView> selectionGray.png" leftCapWidth:0 topCapHeight:0];
}

+ (UIImage *)_segmentedControlButtonImage 
{
    return [self _frameworkImageWithName:@"<UISegmentedControl> button.png" leftCapWidth:6 topCapHeight:0];
}

+ (UIImage *)_segmentedControlHighlightedButtonImage 
{    
    return [self _frameworkImageWithName:@"<UISegmentedControl> button-highlighted.png" leftCapWidth:6 topCapHeight:0];
}

+ (UIImage *)_segmentedControlDividerImage 
{    
    return [self _frameworkImageWithName:@"<UISegmentedControl> divider.png" leftCapWidth:0 topCapHeight:0];
}

+ (UIImage *)_segmentedControlHighlightedDividerImage
{
    return [self _frameworkImageWithName:@"<UISegmentedControl> divider-highlighted.png" leftCapWidth:0 topCapHeight:0];
}

+ (UIImage *)_switchOnImage
{
    return [self _frameworkImageWithName:@"<UISwitch> on.png" leftCapWidth:0 topCapHeight:0];
}

+ (UIImage *)_switchOffImage
{
    return [self _frameworkImageWithName:@"<UISwitch> off.png" leftCapWidth:0 topCapHeight:0];
}

- (UIImage *)_toolbarImage
{
    // NOTE.. I don't know where to put this, really, but it seems like the real UIKit reduces image size by 75% if they are too
    // big for a toolbar. That seems funky, but I guess here is as good a place as any to do that? I don't really know...

    CGSize imageSize = self.size;
    CGSize size = CGSizeZero;
    
    if (imageSize.width > 24 || imageSize.height > 24) {
        size.height = imageSize.height * 0.75f;
        size.width = imageSize.width / imageSize.height * size.height;
    } else {
        size = imageSize;
    }
    
    CGRect rect = CGRectMake(0,0,size.width,size.height);
    
    UIGraphicsBeginImageContext(size);
    [[UIColor colorWithRed:101/255.f green:104/255.f blue:121/255.f alpha:1] setFill];
    UIRectFill(rect);
    [self drawInRect:rect blendMode:kCGBlendModeDestinationIn alpha:1];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

+ (UIImage *)_tabBarBackgroundImage
{
    return [self _frameworkImageWithName:@"<UITabBar> background.png" leftCapWidth:3 topCapHeight:5];
}

+ (UIImage *)_tabBarButtonImage
{
    return [self _frameworkImageWithName:@"<UITabBar> button.png" leftCapWidth:8 topCapHeight:8];
}

+ (UIImage *)_highlightedTabBarImage
{
    return [self _frameworkImageWithName:@"<UITabBarButtonImage> highlighted.png" leftCapWidth:3 topCapHeight:5];
}

+ (UIImage *)_tabBarButtonBadgeImage
{
    return [self _frameworkImageWithName:@"<UITabBarButtonBadge> background.png" leftCapWidth:6 topCapHeight:8];
}

+ (UIImage *)_defaultNavigationBarBackgroundImage
{
	return [self _frameworkImageWithName:@"<UINavigationBarBackground> default.png" leftCapWidth:0 topCapHeight:0];
}

+ (UIImage *)_blackTranslucentNavigationBarBackgroundImage
{
	return [self _frameworkImageWithName:@"<UINavigationBarBackground> blackTranslucent.png" leftCapWidth:0 topCapHeight:0];
}

+ (UIImage *)_blackOpaqueNavigationBarBackgroundImage
{
	return [self _frameworkImageWithName:@"<UINavigationBarBackground> blackOpaque.png" leftCapWidth:0 topCapHeight:0];
}

+ (UIImage *)_tabBarItemImage
{
    return [self _frameworkImageWithName:@"<UITabBar> item.png" leftCapWidth:3 topCapHeight:5];
}

@end
