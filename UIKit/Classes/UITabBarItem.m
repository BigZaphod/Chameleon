//
//  UITabBarItem.m
//  UIKit
//
//  Created by Peter Steinberger on 23.03.11.
//
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

#import "UITabBarItem.h"
#import "UITabBarButton.h"
#import "UIImage.h"
#import "UIImage+UIPrivate.h"
#import "UIControl.h"

@implementation UITabBarItem
- (id)initWithTitle:(NSString *)title image:(UIImage *)image tag:(NSInteger)tag
{
    if ((self = [super init])) {
        self.title = title;
        self.image = image;
        self.tag = tag;
    }
    return self;
}

- (id)initWithTabBarSystemItem:(UITabBarSystemItem)systemItem tag:(NSInteger)tag
{
    if ((self = [super init])) {
        _isSystemItem = YES;
        _systemItem = systemItem;
        self.tag = tag;
    }
    return self;
}

- (void)dealloc
{
    [_badgeValue release];
    [super dealloc];
}

- (NSString *)badgeValue
{
    return _badgeValue;
}

- (void)setBadgeValue:(NSString *)badgeValue
{
    if (_badgeValue == badgeValue || [_badgeValue isEqualToString:badgeValue])
        return;

    [_badgeValue release];
    _badgeValue = [badgeValue copy];

    if (!_view || ![_view isKindOfClass:[UITabBarButton class]])
        return;

    UITabBarButton *control = (UITabBarButton *)_view;
    [control setBadgeValue:badgeValue];
}

- (void)setEnabled:(BOOL)enabled
{
    if ([self isEnabled] == enabled)
        return;

    [super setEnabled:enabled];

    if (!_view || ![_view isKindOfClass:[UIControl class]])
        return;

    UIControl *control = (UIControl *)_view;
    [control setEnabled:enabled];
}

- (void)setImage:(UIImage *)image
{
    if ([self image] == image)
        return;

    [super setImage:image];

    if (!_view)
        return;

    if ([_view isKindOfClass:[UITabBarButton class]])
        [(UITabBarButton *)_view _updateImageAndTitleFromTabBarItem:self];
    else if ([_view isKindOfClass:[UIControl class]])
        [(UIButton *)_view setImage:image forState:UIControlStateNormal];
    else if ([_view respondsToSelector:@selector(setImage:)])
        [_view performSelector:@selector(setImage:) withObject:image];
}

- (void)setImageInsets:(UIEdgeInsets)imageInsets
{
    if (UIEdgeInsetsEqualToEdgeInsets([self imageInsets], imageInsets))
        return;

    [super setImageInsets:imageInsets];

    if (!_view)
        return;

    if ([_view isKindOfClass:[UIButton class]])
        [(UIButton *)_view setImageEdgeInsets:imageInsets];
}

- (void)setTitle:(NSString *)title
{
    if ([self title] == title)
        return;

    [super setTitle:title];

    if (!_view)
        return;

    if ([_view isKindOfClass:[UITabBarButton class]])
        [(UITabBarButton *)_view _updateImageAndTitleFromTabBarItem:self];
    else if ([_view isKindOfClass:[UIControl class]])
        [(UIButton *)_view setTitle:title forState:UIControlStateNormal];
    else if ([_view respondsToSelector:@selector(setTitle::)])
        [_view performSelector:@selector(setTitle:) withObject:title];
}
@end
