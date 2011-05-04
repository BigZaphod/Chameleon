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

#import "UITabBarController.h"
#import "UITabBar.h"
#import "UIViewController+UIPrivate.h"

@implementation UITabBarController

@synthesize tabBar = _tabBar;
@synthesize delegate = _delegate;

- (id)initWithNibName:(NSString *)nibName bundle:(NSBundle *)nibBundle
{
    if ((self = [super initWithNibName:nibName bundle:nibBundle])) {
        _tabBar = [[UITabBar alloc] initWithFrame:CGRectZero];
        [_tabBar setDelegate:self];
    }
    return self;
}

- (void)dealloc
{
    [_tabBar release];
    [_viewControllerByTabBarItem release];
    [super dealloc];
}

- (NSArray *)viewControllers
{
    return _viewControllers;
}

- (void)setViewControllers:(NSArray *)viewControllers
{
    [self setViewControllers:viewControllers animated:YES];
}

- (void)setViewControllers:(NSArray *)viewControllers animated:(BOOL)animated
{
    if (_viewControllers != viewControllers && ![_viewControllers isEqualToArray:viewControllers]) {
        NSArray *oldViewControllers = _viewControllers;
        _viewControllers = [viewControllers copy];

        [oldViewControllers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [[obj view] removeFromSuperview];
        }];
        [oldViewControllers release];

        UIView *contentView = [self view];
        NSMutableArray *tabBarItems = [NSMutableArray arrayWithCapacity:[viewControllers count]];
        NSMutableDictionary *viewControllerByTabBarItem = [NSMutableDictionary dictionary];
        [viewControllers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            UIViewController *viewController = (UIViewController *)obj;
            [viewController _setTabBarController:self];
            [tabBarItems addObject:[viewController tabBarItem]];
            [viewControllerByTabBarItem setObject:viewController forKey:[NSString stringWithFormat:@"%p", [viewController tabBarItem]]];

            UIView *view = [viewController view];
            [view setHidden:YES];
            [contentView insertSubview:view belowSubview:_tabBar];
        }];

        _selectedViewController = nil;
        [_tabBar setItems:tabBarItems animated:animated];

        [_viewControllerByTabBarItem release];
        _viewControllerByTabBarItem = [[NSDictionary alloc] initWithDictionary:viewControllerByTabBarItem];
    }
}

- (void)_updateSelectionOnButtonDown:(UITabBarItem *)item
{
    UIViewController *selectedViewController = [_viewControllerByTabBarItem objectForKey:[NSString stringWithFormat:@"%p", item]];
    if ([_viewControllers containsObject:selectedViewController]) {
        BOOL shouldSelectViewController = YES;
        if (_delegate && [_delegate respondsToSelector:@selector(tabBarController:shouldSelectViewController:)])
            shouldSelectViewController = [_delegate tabBarController:self shouldSelectViewController:selectedViewController];

        if (shouldSelectViewController) {
            [self setSelectedViewController:selectedViewController];
            if (_delegate && [_delegate respondsToSelector:@selector(tabBarController:didSelectViewController:)])
                [_delegate tabBarController:self didSelectViewController:_selectedViewController];
        } else {
            [_tabBar setSelectedItem:[_selectedViewController tabBarItem]];
        }
    }
}

- (void)_setSelectedViewController:(UIViewController *)selectedViewController
{
    if (_selectedViewController != selectedViewController && [_viewControllers containsObject:selectedViewController]) {
        [[_selectedViewController view] setHidden:YES];
        _selectedViewController = selectedViewController;
        [[_selectedViewController view] setHidden:NO];
        [_tabBar setSelectedItem:[_selectedViewController tabBarItem]];
    }
}

- (UIViewController *)selectedViewController
{
    return _selectedViewController;
}

- (void)setSelectedViewController:(UIViewController *)selectedViewController
{
    [self _setSelectedViewController:selectedViewController];
}

- (NSUInteger)selectedIndex
{
    return [_viewControllers indexOfObject:_selectedViewController];
}

- (void)setSelectedIndex:(NSUInteger)selectedIndex
{
    [self _setSelectedViewController:[_viewControllers objectAtIndex:selectedIndex]];
}

- (void)loadView
{
    [super loadView];

    CGRect viewBounds = [[self view] bounds];
    CGRect tabBarFrame = [_tabBar frame];
    tabBarFrame.origin.y = CGRectGetHeight(viewBounds) - CGRectGetHeight(tabBarFrame);
    tabBarFrame.size.width = CGRectGetWidth(viewBounds);

    [_tabBar setFrame:tabBarFrame];
    [_tabBar setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin];
    [[self view] addSubview:_tabBar];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (!_selectedViewController)
        [self setSelectedViewController:[_viewControllers objectAtIndex:0]];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: %p>", [self className], self];
}

@end
