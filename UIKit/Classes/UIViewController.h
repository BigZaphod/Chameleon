//
// UIViewController.h
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


#import "UIResponder.h"
#import "UIApplication.h"
#import "UISearchDisplayController.h"
#import "UITabBarItem.h"

@class UITabBarController;

typedef enum {
    UIModalPresentationFullScreen = 0,
    UIModalPresentationPageSheet,
    UIModalPresentationFormSheet,
    UIModalPresentationCurrentContext,
} UIModalPresentationStyle;

typedef enum {
    UIModalTransitionStyleCoverVertical = 0,
    UIModalTransitionStyleFlipHorizontal,
    UIModalTransitionStyleCrossDissolve,
    UIModalTransitionStylePartialCurl,
} UIModalTransitionStyle;

@class UINavigationItem, UINavigationController, UIBarButtonItem, UISplitViewController;

@interface UIViewController : UIResponder 

- (id)initWithNibName:(NSString *)nibName bundle:(NSBundle *)nibBundle;	// won't load a nib no matter what you do!

- (BOOL)isViewLoaded;
- (void)loadView;
- (void)viewDidLoad;
- (void)viewDidUnload;
- (void)viewWillUnload;

- (void)viewWillAppear:(BOOL)animated;
- (void)viewDidAppear:(BOOL)animated;
- (void)viewWillDisappear:(BOOL)animated;
- (void)viewDidDisappear:(BOOL)animated;

- (void)presentModalViewController:(UIViewController *)modalViewController animated:(BOOL)animated;		// works, but not exactly correctly.
- (void)dismissModalViewControllerAnimated:(BOOL)animated;												// see comments in dismissModalViewController

- (void)didReceiveMemoryWarning;	// doesn't do anything and is never called...

- (void)setToolbarItems:(NSArray *)toolbarItems animated:(BOOL)animated;
- (void)setEditing:(BOOL)editing animated:(BOOL)animated;
- (UIBarButtonItem *)editButtonItem;	// not implemented
- (BOOL)disablesAutomaticKeyboardDismissal;

+ (void)attemptRotationToDeviceOrientation;
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation;
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration;
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation;

- (void)addChildViewController:(UIViewController *)childController;

- (BOOL)automaticallyForwardAppearanceAndRotationMethodsToChildViewControllers;
- (void)didMoveToParentViewController:(UIViewController *)parent;
- (void)removeFromParentViewController;
- (void)transitionFromViewController:(UIViewController *)fromViewController 
                    toViewController:(UIViewController *)toViewController 
                            duration:(NSTimeInterval)duration 
                             options:(UIViewAnimationOptions)options 
                          animations:(void (^)(void))animations 
                          completion:(void (^)(BOOL finished))completion;

- (void)willMoveToParentViewController:(UIViewController *)parent;

- (void)viewWillLayoutSubviews;
- (void)viewDidLayoutSubviews;

- (BOOL)isMovingToParentViewController;
- (BOOL)isMovingFromParentViewController;
- (BOOL)isBeingDismissed;
- (BOOL)isBeingPresented;

- (void)dismissViewControllerAnimated:(BOOL)flag completion:(void (^)(void))completion;
- (void)presentViewController:(UIViewController *)viewControllerToPresent animated:(BOOL)flag completion:(void (^)(void))completion;


- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration;

- (UIView *)rotatingHeaderView;     
- (UIView *)rotatingFooterView; 

@property (nonatomic, readonly, copy) NSString *nibName;
@property (nonatomic, readonly, retain) NSBundle *nibBundle;
@property (nonatomic, retain) UIView *view;
@property (nonatomic, assign) BOOL wantsFullScreenLayout;		// doesn't do anything right now
@property (nonatomic, copy) NSString *title;
@property (nonatomic, readonly) UIInterfaceOrientation interfaceOrientation;	// always returns UIInterfaceOrientationLandscapeLeft
@property (nonatomic, readonly, retain) UINavigationItem *navigationItem;
@property (nonatomic, retain) NSArray *toolbarItems;
@property (nonatomic, getter=isEditing) BOOL editing;
@property (nonatomic) BOOL hidesBottomBarWhenPushed;

@property (nonatomic, readwrite) CGSize contentSizeForViewInPopover;
@property (nonatomic,readwrite,getter=isModalInPopover) BOOL modalInPopover;

@property (nonatomic, readonly) UIViewController *modalViewController;
@property (nonatomic, assign) UIModalPresentationStyle modalPresentationStyle;
@property (nonatomic, assign) UIModalTransitionStyle modalTransitionStyle;		// not used right now

@property (nonatomic, readonly) UIViewController *parentViewController;
@property (nonatomic, readonly, retain) UINavigationController *navigationController;
@property (nonatomic, readonly, retain) UISplitViewController *splitViewController;
@property (nonatomic, readonly, retain) UISearchDisplayController *searchDisplayController; // stub

@property (nonatomic, readonly) NSArray *childViewControllers;

// stubs
@property (nonatomic, retain) UITabBarItem *tabBarItem;
@property (nonatomic, readonly, retain) UITabBarController *tabBarController;

@end
