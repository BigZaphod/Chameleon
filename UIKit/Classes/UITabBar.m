//
//  UITabBar.m
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

#import "UITabBar.h"
#import "UITabBarItem.h"
#import "UITabBarButton.h"
#import "UIImageView.h"
#import "UIImage+UIPrivate.h"
#import "UIColor.h"
#import <QuartzCore/QuartzCore.h>

#define TABBAR_HEIGHT 60.0

@implementation UITabBar

@synthesize delegate = _delegate;

- (id)initWithFrame:(CGRect)rect
{
    rect.size.height = TABBAR_HEIGHT; // tabbar is always fixed
    if ((self = [super initWithFrame:rect])) {
        self.backgroundColor = [UIColor clearColor];
        _selectedItem = nil;

        UIImage *backgroundImage = [UIImage _tabBarBackgroundImage];
        UIImageView *backgroundView = [[UIImageView alloc] initWithImage:backgroundImage];
        backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        backgroundView.frame = rect;
        [self addSubview:backgroundView];
        [backgroundView release];
    }
    return self;
}

- (void)dealloc
{
    _delegate = nil;
    [_items release];
    [super dealloc];
}

- (void)_buttonDown:(id)sender
{
    for (UITabBarItem *item in _items) {
        if (item->_view == sender) {
            [self setSelectedItem:item];
            break;
        }
    }

    if (_delegate && [_delegate respondsToSelector:@selector(tabBar:didSelectItem:)])
        [_delegate tabBar:self didSelectItem:_selectedItem];

}

- (UITabBarItem *)selectedItem
{
    return _selectedItem;
}

- (void)setSelectedItem:(UITabBarItem *)selectedItem
{
    if (_selectedItem != selectedItem && ([_items containsObject:selectedItem] || !selectedItem)) {
        if (_selectedItem)
            [(UIButton *)_selectedItem->_view setSelected:NO];

        _selectedItem = selectedItem;

        if (_selectedItem)
            [(UIButton *)_selectedItem->_view setSelected:YES];
    }
}

- (NSArray *)items
{
    return _items;
}

- (void)setItems:(NSArray *)items animated:(BOOL)animated
{
    if (_items == items || [_items isEqualToArray:items])
        return;

    // if animated, fade old item views out, otherwise just remove them
    for (UITabBarItem *tabBarItem in _items) {
        UIView *view = tabBarItem->_view;
        if (view) {
            if (animated) {
                [UIView beginAnimations:@"fadeOut" context:NULL];
                [UIView setAnimationDidStopSelector:@selector(removeFromSuperview)];
                [UIView setAnimationDelegate:view];
                view.alpha = 0;
                [UIView commitAnimations];
            } else {
                [view removeFromSuperview];
            }
        }

    }

    _selectedItem = nil;
    [_items release];
    _items = [items copy];

    for (UITabBarItem *item in _items) {
        UIView *view = item->_view;
        if (view) {
            // FIXME: What happens when we try to use a tab item that already has a button view?
            if ([view isKindOfClass:[UIButton class]]) {
                UIButton *button = (UIButton *)view;
                [button removeTarget:item->_target action:item->_action forControlEvents:UIControlEventTouchDown];
                item->_target = self;
                item->_action = @selector(_buttonDown:);
                [button addTarget:item->_target action:item->_action forControlEvents:UIControlEventTouchDown];
                [button setSelected:NO];
                [button setHighlighted:NO];
                [button setHidden:NO];
                [button removeFromSuperview];
            }
        } else {
            item->_target = self;
            item->_action = @selector(_buttonDown:);
            view = [[UITabBarButton alloc] initWithTabBarItem:item];
            item->_view = view;
        }
        [self addSubview:item->_view];

        // if animated, fade them in
        if (view && animated) {
            view.alpha = 0;
            [UIView beginAnimations:@"fadeIn" context:NULL];
            view.alpha = 1;
            [UIView commitAnimations];
        }
    }
}

- (void)setItems:(NSArray *)items
{
    [self setItems:items animated:NO];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    if (!_items || [_items count] == 0)
        return;

    CGFloat width = ceilf(CGRectGetWidth(self.bounds) / (CGFloat)[_items count]);
    CGRect frame = CGRectMake(0.0f, 0.0f, width, CGRectGetHeight(self.bounds));
    for (UITabBarItem *item in _items)
    {
        assert(item->_view);
        UIView *view = item->_view;
        [view setFrame:frame];
        frame.origin.x = CGRectGetMaxX(frame);
    }
}

- (void)beginCustomizingItems:(NSArray *)items
{
}

- (BOOL)endCustomizingAnimated:(BOOL)animated
{
    return YES;
}

- (BOOL)isCustomizing
{
    return NO;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: %p; selectedItem = %@; items = %@; delegate = %@>", [self className], self, self.selectedItem, self.items, self.delegate];
}

@end
