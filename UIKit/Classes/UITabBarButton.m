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

#import "UITabBarButton.h"
#import "UITabBarItem.h"
#import "UIGraphics.h"
#import "UIImageView.h"
#import "UIImage+UIPrivate.h"
#import "UIFont.h"
#import "UILabel.h"
#import "UIColor.h"
#import <QuartzCore/QuartzCore.h>

@implementation UITabBarButton

- (id)initWithTabBarItem:(UITabBarItem *)item
{
    CGRect frame = CGRectMake(0,0,24,24);

    if ((self = [super initWithFrame:frame])) {
        [self _updateImageAndTitleFromTabBarItem:item];
        UIImage *backgroundImage = [UIImage _tabBarButtonImage];

        // Set the button's properties
        [self setFrame:frame];
        [self setEnabled:[item isEnabled]];
        [self setBadgeValue:[item badgeValue]];
        [self setImageEdgeInsets:[item imageInsets]];
        [self addTarget:item->_target action:item->_action forControlEvents:UIControlEventTouchDown];

        [self setTitleColor:[UIColor colorWithWhite:0.6f alpha:1.f] forState:UIControlStateNormal];
        [self setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];

        [self setBackgroundImage:backgroundImage forState:UIControlStateSelected];

        CALayer *imageLayer = [[self imageView] layer];
        imageLayer.shadowColor = [[UIColor blackColor] CGColor];
        imageLayer.shadowOpacity = 1.0f;
        imageLayer.shadowRadius = 2.0f;
        imageLayer.shadowOffset = CGSizeMake(1.0f, 3.0f);

        CALayer *textLayer = [[self titleLabel] layer];
        textLayer.shadowColor = [[UIColor blackColor] CGColor];
        textLayer.shadowOpacity = 1.0f;
        textLayer.shadowRadius = 2.0f;
        textLayer.shadowOffset = CGSizeMake(1.0f, 3.0f);
    }
    return self;
}

- (void)dealloc
{
    [_buttonBadge release];
    [super dealloc];
}

CGSize _CGSizeAspectFitToSize(const CGSize original, const CGSize constraint)
{
    if (original.width <= constraint.width && original.height <= constraint.height)
        return original;

    CGSize result = original;
    if (result.width > constraint.width) {
        result.height = constraint.width;
        result.height = roundf(result.width * (original.height / original.width));
    }

    if (result.height > constraint.height) {
        result.height = constraint.height;
        result.width = roundf(result.height * (original.width / original.height));
    }

    return result;
}

- (void)_updateImageAndTitleFromTabBarItem:(UITabBarItem *)item
{
    // Figure out the image and title to use
    UIImage *image = nil;
    NSString *title = nil;

    if (item->_isSystemItem) {
        // TODO: Get the system image
        switch (item->_systemItem) {
            case UITabBarSystemItemMore:
                title = @"More";
                break;
            case UITabBarSystemItemFavorites:
                title = @"Favorites";
                break;
            case UITabBarSystemItemFeatured:
                title = @"Featured";
                break;
            case UITabBarSystemItemTopRated:
                title = @"Top Rated";
                break;
            case UITabBarSystemItemRecents:
                title = @"Recent Items";
                break;
            case UITabBarSystemItemContacts:
                title = @"Contacts";
                break;
            case UITabBarSystemItemHistory:
                title = @"History";
                break;
            case UITabBarSystemItemBookmarks:
                title = @"Bookmarks";
                break;
            case UITabBarSystemItemSearch:
                title = @"Search";
                break;
            case UITabBarSystemItemDownloads:
                title = @"Downloads";
                break;
            case UITabBarSystemItemMostRecent:
                title = @"Most Recent";
                break;
            case UITabBarSystemItemMostViewed:
                title = @"Most Viewed";
                break;
            default:
                break;
        }
        if (item.title)
            title = item.title;
    } else {
        image = item.image;
        title = item.title;
    }

    [self setTitle:title forState:UIControlStateNormal];

    UIImage *selectedImage = [self _selectedTabBarImageFromImage:image];
    UIImage *unselectedImage = [self _unselectedTabBarImageFromImage:image];
    [self setImage:unselectedImage forState:UIControlStateNormal];
    [self setImage:selectedImage forState:UIControlStateSelected];
}

- (UIImage *)_unselectedTabBarImageFromImage:(UIImage *)image
{
    CGRect rect = CGRectZero;
    rect.size = _CGSizeAspectFitToSize(image.size, CGSizeMake(24.0f, 24.0f));

    if (!image || CGRectIsEmpty(rect))
      return nil;

    UIGraphicsBeginImageContext(rect.size);
    [[UIColor colorWithWhite:0.6f alpha:1.f] setFill];
    UIRectFill(rect);
    [image drawInRect:rect blendMode:kCGBlendModeDestinationIn alpha:1];
    UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return result;
}

- (UIImage *)_selectedTabBarImageFromImage:(UIImage *)image
{
    // TODO: We still need to create an inner outline to the image that is actually the original image with kCGBlendModeLighten set
    CGRect rect = CGRectZero;
    rect.size = _CGSizeAspectFitToSize(image.size, CGSizeMake(24.0f, 24.0f));

    if (!image || CGRectIsEmpty(rect))
        return nil;

    UIImage *highlightedImage = [UIImage _highlightedTabBarImage];
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef ctx = UIGraphicsGetCurrentContext();

    // translate/flip the graphics context (for transforming from CG* coords to UI* coords)
    CGContextTranslateCTM(ctx, 0, rect.size.height);
    CGContextScaleCTM(ctx, 1.0, -1.0);

    // set a mask that matches the shape of the image, then draw (color burn) a colored rectangle
    CGContextClipToMask(ctx, rect, image.CGImage);
    CGContextDrawImage(ctx, rect, highlightedImage.CGImage);

    UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return result;
}

- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    return NO;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    self.highlighted = NO;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesMoved:touches withEvent:event];
    self.highlighted = NO;
}

- (CGRect)_componentRectForSize:(CGSize)size inContentRect:(CGRect)contentRect withState:(UIControlState)state
{
    return CGRectMake(roundf(CGRectGetMidX(contentRect) - size.width / 2.0f),
                      roundf(CGRectGetMidY(contentRect) - size.height / 2.0f),
                      size.width, size.height);
}

- (CGRect)imageRectForContentRect:(CGRect)contentRect
{
    const UIControlState state = self.state;

    UIImage *image  = [self imageForState:state];
    CGSize imageSize = (image ? [image size] : CGSizeMake(24.0f, 24.0f));

    NSString *title = [self titleForState:state];
    CGSize titleSize = (title ? [title sizeWithFont:[[self titleLabel] font]] : CGSizeZero);

    UIEdgeInsets inset = [self imageEdgeInsets];
    inset.bottom += titleSize.height;

    return [self _componentRectForSize:imageSize inContentRect:UIEdgeInsetsInsetRect(contentRect, inset) withState:state];
}

- (CGRect)titleRectForContentRect:(CGRect)contentRect
{
    const UIControlState state = self.state;

    NSString *title = [self titleForState:state];
    CGSize titleSize = (title ? [title sizeWithFont:[[self titleLabel] font]] : CGSizeZero);

    UIImage *image  = [self imageForState:state];
    CGSize imageSize = (image ? [image size] : CGSizeMake(24.0f, 24.0f));

    UIEdgeInsets inset = [self titleEdgeInsets];
    inset.top += imageSize.height;

    return [self _componentRectForSize:titleSize inContentRect:UIEdgeInsetsInsetRect(contentRect, inset) withState:state];
}

- (void)layoutSubviews
{
    [super layoutSubviews];

    if (!_buttonBadge)
        return;

    const CGRect bounds = self.bounds;
    const CGRect contentFrame = CGRectUnion([self imageRectForContentRect:bounds], [self titleRectForContentRect:bounds]);

    CGRect badgeFrame = CGRectZero;
    badgeFrame.size = [_buttonBadge sizeThatFits:bounds.size];

    badgeFrame.origin.x = roundf(CGRectGetMaxX(contentFrame) - CGRectGetWidth(badgeFrame) / 2.0f);
    badgeFrame.origin.y = roundf(CGRectGetMinY(contentFrame) - CGRectGetHeight(badgeFrame) / 2.0f) + 5.0f;

    if (CGRectGetMaxX(badgeFrame) > CGRectGetWidth(bounds))
        badgeFrame.origin.x = CGRectGetWidth(bounds) - CGRectGetWidth(badgeFrame);

    [_buttonBadge setFrame:badgeFrame];
}

- (NSString *)badgeValue
{
    if (!_buttonBadge)
        return nil;

    return [_buttonBadge text];
}

- (void)setBadgeValue:(NSString *)badgeValue
{
    if (!badgeValue || [badgeValue length] == 0)
    {
        if (_buttonBadge) {
            [_buttonBadge removeFromSuperview];
            [_buttonBadge release];
            _buttonBadge = nil;
        }
        return;
    }

    if (!_buttonBadge)
    {
        _buttonBadge = [[UITabBarButtonBadge alloc] init];
        [self addSubview:_buttonBadge];
    }

    [_buttonBadge setText:badgeValue];
}
@end
