//
// UIViewController.m
//
// Original Author:
//  The IconFactory
//
// Contributor: 
//	Zac Bowling <zac@seatme.com>
//
// Copyright (C) 2011 SeatMe, Inc http://www.seatme.com
//
// Permission is hereby granted, free of charge, to any person obtaining
// a copy of this software and associated documentation files (the
// "Software"), to deal in the Software without restriction, including
// without limitation the rights to use, copy, modify, merge, publish,
// distribute, sublicense, and/or sell copies of the Software, and to
// permit persons to whom the Software is furnished to do so, subject to
// the following conditions:
// 
// The above copyright notice and this permission notice shall be
// included in all copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
// EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
// MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
// NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
// LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
// OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
// WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
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

#import "UIViewController+UIPrivate.h"
#import "UIView+UIPrivate.h"
#import "UIScreen.h"
#import "UIWindow.h"
#import "UIScreen.h"
#import "UINavigationItem.h"
#import "UIBarButtonItem.h"
#import "UINavigationController.h"
#import "UISplitViewController.h"
#import "UIToolbar.h"
#import "UIScreen.h"
#import "UITabBarController.h"
#import "UINib.h"

@implementation UIViewController 

@dynamic wantsFullScreenLayout;
@dynamic hidesBottomBarWhenPushed;
@dynamic editing;
@dynamic modalInPopover;

@synthesize navigationItem = _navigationItem;
@synthesize view = _view;
@synthesize title = _title;
@synthesize contentSizeForViewInPopover = _contentSizeForViewInPopover;
@synthesize toolbarItems = _toolbarItems;
@synthesize modalPresentationStyle = _modalPresentationStyle;

@synthesize modalViewController = _modalViewController;
@synthesize parentViewController = _parentViewController;
@synthesize modalTransitionStyle = _modalTransitionStyle;

@synthesize searchDisplayController = _searchDisplayController;
@synthesize tabBarItem = _tabBarItem;
@synthesize tabBarController = _tabBarController;
@synthesize nibBundle = _nibBundle;
@synthesize nibName = _nibName;

@synthesize childViewControllers=_childViewControllers;

- (id)init
{
    return [self initWithNibName:nil bundle:nil];
}

- (id)initWithNibName:(NSString *)nibName bundle:(NSBundle *)nibBundle
{
    if (nil != (self = [super init])) {
        _nibName = [nibName copy];
        _nibBundle = [nibBundle retain];
        _contentSizeForViewInPopover = CGSizeMake(320,1100);
    }
    return self;
}

- (void)dealloc
{
    [_view _setViewController:nil];
    [_modalViewController release];
    [_navigationItem release];
    [_title release];
    [_view release];
    [_nibName release];
    [_nibBundle release];
    [super dealloc];
}

- (UIResponder *)nextResponder
{
    return _view.superview;
}

- (BOOL) isModalInPopover
{
    return _flags.modalInPopover;
}

- (void) setModalInPopover:(BOOL)modalInPopover
{
    _flags.modalInPopover = modalInPopover;
}

- (BOOL) wantsFullScreenLayout
{
    return _flags.wantsFullScreenLayout;
}

- (void) setWantsFullScreenLayout:(BOOL)wantsFullScreenLayout
{
    _flags.wantsFullScreenLayout = wantsFullScreenLayout;
}

- (BOOL) hidesBottomBarWhenPushed
{
    return _flags.hidesBottomBarWhenPushed;
}

- (void) setHidesBottomBarWhenPushed:(BOOL)hidesBottomBarWhenPushed
{
    _flags.hidesBottomBarWhenPushed = hidesBottomBarWhenPushed;
}

- (BOOL)isViewLoaded
{
    return (_view != nil);
}

- (UIView *)view
{
    if (!_flags.viewLoadedFromControllerNib) {
        _flags.viewLoadedFromControllerNib = YES;
        [self loadView];
        [self viewDidLoad];
    }
    return _view;
}

- (void)setView:(UIView *)aView
{
    if (aView != _view) {
        [_view _setViewController:nil];
        [_view release];
        _view = [aView retain];
        [_view _setViewController:self];
    }
}

- (void)loadView
{
    if (self.nibName) {
        [[UINib nibWithNibName:self.nibName bundle:self.nibBundle] instantiateWithOwner:self options:nil];
    } else {
        self.view = [[[UIView alloc] initWithFrame:CGRectMake(0,0,320,480)] autorelease];
    }
}

- (void)viewDidLoad
{
}

- (void)viewDidUnload
{
}

- (void)viewWillUnload
{
}

- (void)didReceiveMemoryWarning
{
}

- (void)viewWillAppear:(BOOL)animated
{
}

- (void)viewDidAppear:(BOOL)animated
{
}

- (void)viewWillDisappear:(BOOL)animated
{
}

- (void)viewDidDisappear:(BOOL)animated
{
}

- (UIInterfaceOrientation)interfaceOrientation
{

    return (UIInterfaceOrientation) UIDeviceOrientationPortrait;

}

- (UINavigationItem *)navigationItem
{
    if (!_navigationItem) {
        _navigationItem = [[UINavigationItem alloc] initWithTitle:self.title];
    }
    return _navigationItem;
}

- (void)_setParentViewController:(UIViewController *)parentController
{
    _parentViewController = parentController;
}

- (void)setToolbarItems:(NSArray *)theToolbarItems animated:(BOOL)animated
{
    if (_toolbarItems != theToolbarItems) {
        [_toolbarItems release];
        _toolbarItems = [theToolbarItems retain];
        [self.navigationController.toolbar setItems:_toolbarItems animated:animated];
    }
}

- (void)setToolbarItems:(NSArray *)theToolbarItems
{
    [self setToolbarItems:theToolbarItems animated:NO];
}

- (BOOL) isEditing
{
    return _flags.editing;
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    _flags.editing = editing;
}

- (void)setEditing:(BOOL)editing
{
    [self setEditing:editing animated:NO];
}

- (UIBarButtonItem *)editButtonItem
{
    // this should really return a fancy bar button item that toggles between edit/done and sends setEditing:animated: messages to this controller
    return nil;
}

- (void)presentModalViewController:(UIViewController *)modalViewController animated:(BOOL)animated
{
    if (!_modalViewController && _modalViewController != self) {
        _modalViewController = [modalViewController retain];
        [_modalViewController _setParentViewController:self];

        UIWindow *window = self.view.window;
        UIView *selfView = self.view;
        UIView *newView = _modalViewController.view;

        newView.autoresizingMask = selfView.autoresizingMask;
        newView.frame = _flags.wantsFullScreenLayout? window.screen.bounds : window.screen.applicationFrame;

        [window addSubview:newView];
        [_modalViewController viewWillAppear:animated];

        [self viewWillDisappear:animated];
        selfView.hidden = YES;		// I think the real one may actually remove it, which would mean needing to remember the superview, I guess? Not sure...
        [self viewDidDisappear:animated];


        [_modalViewController viewDidAppear:animated];
    }
}

- (void)dismissModalViewControllerAnimated:(BOOL)animated
{
    // NOTE: This is not implemented entirely correctly - the actual dismissModalViewController is somewhat subtle.
    // There is supposed to be a stack of modal view controllers that dismiss in a specific way,e tc.
    // The whole system of related view controllers is not really right - not just with modals, but everything else like
    // navigationController, too, which is supposed to return the nearest nav controller down the chain and it doesn't right now.

    if (_modalViewController) {
        
        // if the modalViewController being dismissed has a modalViewController of its own, then we need to go dismiss that, too.
        // otherwise things can be left hanging around.
        if (_modalViewController.modalViewController) {
            [_modalViewController dismissModalViewControllerAnimated:animated];
        }
        
        self.view.hidden = NO;
        [self viewWillAppear:animated];
        
        [_modalViewController.view removeFromSuperview];
        [_modalViewController _setParentViewController:nil];
        [_modalViewController autorelease];
        _modalViewController = nil;

        [self viewDidAppear:animated];
    } else {
        [self.parentViewController dismissModalViewControllerAnimated:animated];
    }
}

+ (void)attemptRotationToDeviceOrientation
{
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
}

- (void)addChildViewController:(UIViewController *)childController
{
    [childController willMoveToParentViewController:self];
    [childController _setParentViewController:self];
    [_childViewControllers addObject:childController];
}

- (void)removeFromParentViewController
{
    [self willMoveToParentViewController:nil];
    [self _setParentViewController:nil];
}

- (void)willMoveToParentViewController:(UIViewController *)parent
{
    
}

- (void)didMoveToParentViewController:(UIViewController *)parent
{
    
}

- (void)transitionFromViewController:(UIViewController *)fromViewController toViewController:(UIViewController *)toViewController duration:(NSTimeInterval)duration options:(UIViewAnimationOptions)options animations:(void (^)(void))animations completion:(void (^)(BOOL finished))completion
{
    [fromViewController beginAppearanceTransition:NO animated:duration > 0];
    [toViewController beginAppearanceTransition:YES animated:duration > 0];
    [UIView animateWithDuration:duration
        animations:animations
        completion:^(BOOL finished){
            if (completion) {
                completion(finished);
            }
            [fromViewController _endAppearanceTransition];
            [toViewController _endAppearanceTransition];
        }
     ];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation 
                                         duration:(NSTimeInterval)duration
{
    
}

- (id)_nearestParentViewControllerThatIsKindOf:(Class)c
{
    UIViewController *controller = _parentViewController;

    while (controller && ![controller isKindOfClass:c]) {
        controller = [controller parentViewController];
    }

    return controller;
}

- (UINavigationController *)navigationController
{
    return [self _nearestParentViewControllerThatIsKindOf:[UINavigationController class]];
}

- (UISplitViewController *)splitViewController
{
    return [self _nearestParentViewControllerThatIsKindOf:[UISplitViewController class]];
}

- (BOOL)automaticallyForwardAppearanceAndRotationMethodsToChildViewControllers 
{
    return YES;
}


- (void)viewWillLayoutSubviews 
{
    
}

- (void)viewDidLayoutSubviews 
{
    
}

- (BOOL)isMovingToParentViewController
{
    //TODO
    return FALSE;
}

- (BOOL)isMovingFromParentViewController
{
    //TODO
    return FALSE;
}

- (BOOL)isBeingDismissed 
{
    //TODO
    return FALSE;
}

- (BOOL)isBeingPresented
{
    //TODO
    return FALSE;
}

- (BOOL)disablesAutomaticKeyboardDismissal 
{
    return FALSE;
}

- (void)dismissViewControllerAnimated:(BOOL)flag completion:(void (^)(void))completion
{
    
}

- (void)presentViewController:(UIViewController *)viewControllerToPresent animated:(BOOL)flag completion:(void (^)(void))completion
{
    
}

- (NSArray *)childViewControllers
{
    return [[_childViewControllers retain] autorelease];
}

- (void)setChildViewControllers:(NSArray *)childViewControllers 
{

}


- (void)_setViewAppearState:(UIViewControllerAppearState)appearState isAnimating:(BOOL)animating
{
    if (_appearState != appearState) {
        _appearState = appearState;
        switch (_appearState) {
            case UIViewControllerStateWillAppear: {
                [self viewWillAppear:animating];
                break;
            }
            case UIViewControllerStateDidAppear: {
                [self viewDidAppear:animating];
                break;
            } 
            case UIViewControllerStateWillDisappear: {
                [self viewWillDisappear:animating];
                break;
            }  
            case UIViewControllerStateDidDisappear: {
                [self viewDidDisappear:animating];
                break;
            }
        }
    }
}

- (void)viewWillMoveToWindow:(UIWindow *)window
{
    if (!_flags.isInAnimatedVCTransition) {
        if (window) {
            [self _setViewAppearState:UIViewControllerStateWillAppear isAnimating:NO];
        } else {
            [self _setViewAppearState:UIViewControllerStateWillDisappear isAnimating:NO];
        }
    }
}

- (void)viewDidMoveToWindow:(UIWindow *)window
{
    if (!_flags.isInAnimatedVCTransition) {
        if (window) {
            [self _setViewAppearState:UIViewControllerStateDidAppear isAnimating:NO];
        } else {
            [self _setViewAppearState:UIViewControllerStateDidDisappear isAnimating:NO];
        }
    }
}

- (BOOL)beginAppearanceTransition:(BOOL)shouldAppear animated:(BOOL)animated
{
    _flags.isInAnimatedVCTransition = YES;
    UIViewControllerAppearState appearState;
    if (shouldAppear) {
        appearState = UIViewControllerStateWillAppear;
    } else {
        appearState = UIViewControllerStateWillDisappear;
    }
    [self _setViewAppearState:appearState isAnimating:animated];
    return YES;
}

- (BOOL)_endAppearanceTransition
{
    if (_flags.isInAnimatedVCTransition) {
        UIViewControllerAppearState appearState;
        if (_appearState == UIViewControllerStateWillAppear) {
            appearState = UIViewControllerStateDidAppear;
        } else if (_appearState == UIViewControllerStateWillDisappear) {
            appearState = UIViewControllerStateDidDisappear;
        } else {
            return NO;
        }
        [self _setViewAppearState:appearState isAnimating:NO];
        return YES;
    }
    return NO;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: %p; title = %@; view = %@>", [self className], self, self.title, self.view];
}

- (UIView *)rotatingHeaderView {
    return nil;
}

- (UIView *)rotatingFooterView {
    return nil;
}


@end
