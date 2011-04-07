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

#import "UINavigationController.h"
#import "UIViewController+UIPrivate.h"
#import "UITabBarController.h"
#import "UINavigationBar.h"
#import "UIToolbar.h"

static const NSTimeInterval kAnimationDuration = 0.33;
static const CGFloat NavBarHeight = 28;
static const CGFloat ToolbarHeight = 28;

@implementation UINavigationController
@synthesize viewControllers=_viewControllers, delegate=_delegate, navigationBar=_navigationBar;
@synthesize toolbar=_toolbar, toolbarHidden=_toolbarHidden, navigationBarHidden=_navigationBarHidden;

- (id)initWithNibName:(NSString *)nibName bundle:(NSBundle *)bundle
{
    if ((self=[super initWithNibName:nibName bundle:bundle])) {
        _viewControllers = [[NSMutableArray alloc] initWithCapacity:1];
        _navigationBar = [[UINavigationBar alloc] init];
        _navigationBar.delegate = self;
        _toolbar = [[UIToolbar alloc] init];
        _toolbarHidden = YES;
    }
    return self;
}

- (id)initWithRootViewController:(UIViewController *)rootViewController
{
    if ((self=[self initWithNibName:nil bundle:nil])) {
        self.viewControllers = [NSArray arrayWithObject:rootViewController];
    }
    return self;
}

- (void)dealloc
{
    [_viewControllers release];
    [_navigationBar release];
    [_toolbar release];
    [super dealloc];
}

- (void)setDelegate:(id<UINavigationControllerDelegate>)newDelegate
{
    _delegate = newDelegate;
    _delegateHas.didShowViewController = [_delegate respondsToSelector:@selector(navigationController:didShowViewController:animated:)];
    _delegateHas.willShowViewController = [_delegate respondsToSelector:@selector(navigationController:willShowViewController:animated:)];
}

- (CGRect)_navigationBarFrame
{
    CGRect navBarFrame = self.view.bounds;
    navBarFrame.size.height = NavBarHeight;
    return navBarFrame;
}

- (CGRect)_toolbarFrame
{
    CGRect toolbarRect = self.view.bounds;
    toolbarRect.origin.y = toolbarRect.origin.y + toolbarRect.size.height - ToolbarHeight;
    toolbarRect.size.height = ToolbarHeight;
    return toolbarRect;
}

- (CGRect)_controllerFrame
{
    CGRect controllerFrame = self.view.bounds;
    
    // adjust for the nav bar
    if (!self.navigationBarHidden) {
        controllerFrame.origin.y += NavBarHeight;
        controllerFrame.size.height -= NavBarHeight;
    }
    
    // adjust for toolbar (if there is one)
    if (!self.toolbarHidden) {
        controllerFrame.size.height -= ToolbarHeight;
    }
    
    return controllerFrame;
}

- (void)loadView
{
    self.view = [[[UIView alloc] initWithFrame:CGRectMake(0,0,320,480)] autorelease];
    self.view.clipsToBounds = YES;
    
    UIViewController *topViewController = self.topViewController;
    topViewController.view.frame = [self _controllerFrame];
    topViewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:topViewController.view];
    
    _navigationBar.frame = [self _navigationBarFrame];
    _navigationBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    _navigationBar.hidden = self.navigationBarHidden;
    [self.view addSubview:_navigationBar];
    
    _toolbar.frame = [self _toolbarFrame];
    _toolbar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    _toolbar.hidden = self.toolbarHidden;
    [self.view addSubview:_toolbar];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.topViewController viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.topViewController viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.topViewController viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self.topViewController viewDidDisappear:animated];
}

- (void)_updateToolbar:(BOOL)animated
{
    UIViewController *topController = self.topViewController;
    [_toolbar setItems:topController.toolbarItems animated:animated];
    _toolbar.hidden = self.toolbarHidden;
    topController.view.frame = [self _controllerFrame];
}

- (void)setViewControllers:(NSArray *)newViewControllers animated:(BOOL)animated
{
    assert([newViewControllers count] >= 1);
    if (newViewControllers != _viewControllers) {
        UIViewController *previousTopController = self.topViewController;
        
        if (previousTopController) {
            [previousTopController.view removeFromSuperview];
        }
        
        for (UIViewController *controller in _viewControllers) {
            [controller _setParentViewController:nil];
        }
        
        [_viewControllers release];
        _viewControllers = [newViewControllers mutableCopy];
        
        NSMutableArray *items = [NSMutableArray arrayWithCapacity:[_viewControllers count]];
        
        for (UIViewController *controller in _viewControllers) {
            [controller _setParentViewController:self];
            [items addObject:controller.navigationItem];
        }
        
        if ([self isViewLoaded]) {
            UIViewController *newTopController = self.topViewController;
            newTopController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            
            [newTopController viewWillAppear:animated];
            if (_delegateHas.willShowViewController) {
                [_delegate navigationController:self willShowViewController:newTopController animated:animated];
            }
            
            newTopController.view.frame = [self _controllerFrame];
            [self.view insertSubview:newTopController.view atIndex:0];
            
            [newTopController viewDidAppear:animated];
            if (_delegateHas.didShowViewController) {
                [_delegate navigationController:self didShowViewController:newTopController animated:animated];
            }
        }
        
        [_navigationBar setItems:items animated:animated];
        [self _updateToolbar:animated];
    }
}

- (void)setViewControllers:(NSArray *)newViewControllers
{
    [self setViewControllers:newViewControllers animated:NO];
}

- (UIViewController *)topViewController
{
    return [_viewControllers lastObject];
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    assert(![viewController isKindOfClass:[UITabBarController class]]);
    assert(![_viewControllers containsObject:viewController]);
    
    [viewController _setParentViewController:self];
    
    if ([self isViewLoaded]) {
        UIViewController *oldViewController = self.topViewController;
        
        const CGRect controllerFrame = [self _controllerFrame];
        const CGRect nextFrameStart = CGRectOffset(controllerFrame, controllerFrame.size.width, 0);
        const CGRect nextFrameEnd = controllerFrame;
        const CGRect oldFrameStart = controllerFrame;
        const CGRect oldFrameEnd = CGRectOffset(controllerFrame, -controllerFrame.size.width, 0);
        
        viewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self.view insertSubview:viewController.view atIndex:0];
        
        [viewController viewWillAppear:animated];
        if (_delegateHas.willShowViewController) {
            [_delegate navigationController:self willShowViewController:viewController animated:animated];
        }
        
        if (animated) {
            viewController.view.frame = nextFrameStart;
            oldViewController.view.frame = oldFrameStart;
            
            [oldViewController retain];
            
            [UIView beginAnimations:@"PushViewController" context:(void *)oldViewController];
            [UIView setAnimationDuration:kAnimationDuration];
            [UIView setAnimationDelegate:self];
            [UIView setAnimationDidStopSelector:@selector(_pushAnimationDidStop:finished:removeOldViewController:)];
            viewController.view.frame = nextFrameEnd;
            oldViewController.view.frame = oldFrameEnd;
            [UIView commitAnimations];
        } else {
            viewController.view.frame = nextFrameEnd;
            [oldViewController.view removeFromSuperview];
        }
        
        [viewController viewDidAppear:animated];
        if (_delegateHas.didShowViewController) {
            [_delegate navigationController:self didShowViewController:viewController animated:animated];
        }
    }
    
    [_viewControllers addObject:viewController];
    [_navigationBar pushNavigationItem:viewController.navigationItem animated:animated];
    [self _updateToolbar:animated];
}

- (void)_pushAnimationDidStop:(NSString *)name finished:(NSNumber *)finished removeOldViewController:(UIViewController *)controller
{
    [controller.view removeFromSuperview];
    [controller release];
}

- (UIViewController *)_popViewControllerWithoutPoppingNavigationBarAnimated:(BOOL)animated
{
    if ([_viewControllers count] > 1) {
        UIViewController *oldViewController = [self.topViewController retain];
        
        [_viewControllers removeLastObject];
        [oldViewController _setParentViewController:nil];
        
        if ([self isViewLoaded]) {
            UIViewController *nextViewController = self.topViewController;
            
            const CGRect controllerFrame = [self _controllerFrame];
            const CGRect nextFrameStart = CGRectOffset(controllerFrame, -controllerFrame.size.width, 0);
            const CGRect nextFrameEnd = controllerFrame;
            const CGRect oldFrameStart = controllerFrame;
            const CGRect oldFrameEnd = CGRectOffset(controllerFrame, controllerFrame.size.width, 0);
            
            nextViewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            [self.view insertSubview:nextViewController.view atIndex:0];
            
            [nextViewController viewWillAppear:animated];
            if (_delegateHas.willShowViewController) {
                [_delegate navigationController:self willShowViewController:nextViewController animated:animated];
            }
            
            if (animated) {
                nextViewController.view.frame = nextFrameStart;
                oldViewController.view.frame = oldFrameStart;
                
                [oldViewController retain];
                
                [UIView beginAnimations:@"PopViewController" context:(void *)oldViewController];
                [UIView setAnimationDuration:kAnimationDuration];
                [UIView setAnimationDelegate:self];
                [UIView setAnimationDidStopSelector:@selector(_popAnimationDidStop:finished:removeOldViewController:)];
                nextViewController.view.frame = nextFrameEnd;
                oldViewController.view.frame = oldFrameEnd;
                [UIView commitAnimations];
            } else {
                nextViewController.view.frame = nextFrameEnd;
                [oldViewController.view removeFromSuperview];
            }
            
            [nextViewController viewDidAppear:animated];
            if (_delegateHas.didShowViewController) {
                [_delegate navigationController:self didShowViewController:nextViewController animated:animated];
            }
        }
        
        [self _updateToolbar:animated];
        return [oldViewController autorelease];
    } else {
        return nil;
    }
}

- (void)_popAnimationDidStop:(NSString *)name finished:(NSNumber *)finished removeOldViewController:(UIViewController *)controller
{
    [controller.view removeFromSuperview];
    [controller release];
}

- (UIViewController *)popViewControllerAnimated:(BOOL)animate
{
    UIViewController *controller = [self _popViewControllerWithoutPoppingNavigationBarAnimated:animate];
    if (controller) {
        [_navigationBar popNavigationItemAnimated:animate];
    }
    return controller;
}

- (NSArray *)popToViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    NSMutableArray *popped = [[NSMutableArray alloc] init];
    
    while (self.topViewController != viewController) {
        UIViewController *poppedController = [self popViewControllerAnimated:animated];
        if (poppedController) {
            [popped addObject:poppedController];
        } else {
            break;
        }
    }
    
    return [popped autorelease];
}

- (NSArray *)popToRootViewControllerAnimated:(BOOL)animated
{
    return [self popToViewController:[_viewControllers objectAtIndex:0] animated:animated];
}

- (BOOL)navigationBar:(UINavigationBar *)navigationBar shouldPopItem:(UINavigationItem *)item
{
    [self _popViewControllerWithoutPoppingNavigationBarAnimated:YES];
    return YES;
}

- (void)setToolbarHidden:(BOOL)hidden animated:(BOOL)animated
{
    _toolbarHidden = hidden;
    [self _updateToolbar:animated];
}

- (void)setToolbarHidden:(BOOL)hidden
{
    [self setToolbarHidden:hidden animated:NO];
}

- (BOOL)isToolbarHidden
{
    return _toolbarHidden || self.topViewController.hidesBottomBarWhenPushed;
}

- (void)setContentSizeForViewInPopover:(CGSize)newSize
{
    self.topViewController.contentSizeForViewInPopover = newSize;
}

- (CGSize)contentSizeForViewInPopover
{
    return self.topViewController.contentSizeForViewInPopover;
}

- (void)setNavigationBarHidden:(BOOL)navigationBarHidden animated:(BOOL)animated; // doesn't yet animate
{
    _navigationBarHidden = navigationBarHidden;
    
    // this shouldn't just hide it, but should animate it out of view (if animated==YES) and then adjust the layout
    // so the main view fills the whole space, etc.
    _navigationBar.hidden = navigationBarHidden;
}

- (void)setNavigationBarHidden:(BOOL)navigationBarHidden
{
    [self setNavigationBarHidden:navigationBarHidden animated:NO];
}

@end
