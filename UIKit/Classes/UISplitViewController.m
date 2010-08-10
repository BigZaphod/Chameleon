//  Created by Sean Heber on 7/22/10.
#import "UISplitViewController.h"
#import "UIView.h"
#import "UITouch.h"
#import "UIColor.h"
#import <AppKit/NSCursor.h>

static const CGFloat SplitterPadding = 3;

@interface _UISplitViewControllerView : UIView {
	BOOL dragging;
	UISplitViewController *splitViewController;
	CGFloat leftWidth;
}
- (id)initWithSplitViewController:(UISplitViewController *)theController;
@property (nonatomic, assign) CGFloat leftWidth;
@end

@implementation _UISplitViewControllerView
@synthesize leftWidth;

- (id)initWithSplitViewController:(UISplitViewController *)theController
{
	if ((self=[super initWithFrame:CGRectZero])) {
		splitViewController = theController;
		leftWidth = 320;
		self.backgroundColor = [UIColor blackColor];
	}
	return self;
}

- (void)setLeftWidth:(CGFloat)newWidth
{
	if (newWidth != leftWidth) {
		leftWidth = newWidth;
		[self setNeedsLayout];
	}
}

- (void)layoutSubviews
{
	NSArray *viewControllers = splitViewController.viewControllers;
	const CGRect bounds = self.bounds;
	const CGFloat dividerWidth = 1;
	[[[viewControllers objectAtIndex:0] view] setFrame:CGRectMake(0,0,leftWidth,bounds.size.height)];
	[[[viewControllers objectAtIndex:1] view] setFrame:CGRectMake(leftWidth+dividerWidth,0,MAX(0,(bounds.size.width-leftWidth-dividerWidth)),bounds.size.height)];
}

- (CGRect)splitterHitRect
{
	const CGRect bounds = self.bounds;
	return CGRectMake(leftWidth-SplitterPadding,0,SplitterPadding+SplitterPadding+1,bounds.size.height);
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
	if (CGRectContainsPoint([self splitterHitRect], point)) {
		return self;
	} else {
		return [super hitTest:point withEvent:event];
	}
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	CGPoint point = [[touches anyObject] locationInView:self];

	if (CGRectContainsPoint([self splitterHitRect], point)) {
		dragging = YES;
	}
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
	if (dragging) {
		CGFloat newWidth = [[touches anyObject] locationInView:self].x;
		
		newWidth = MAX(50, newWidth);
		newWidth = MIN(self.bounds.size.width-50, newWidth);
		
		self.leftWidth = newWidth;
	}
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	dragging = NO;
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
	dragging = NO;
}

- (id)mouseCursorForEvent:(UIEvent *)event
{
	CGRect splitterRect = [self splitterHitRect];
	CGPoint point = [[[event allTouches] anyObject] locationInView:self];

	if (dragging && point.x < splitterRect.origin.x) {
		return [NSCursor resizeLeftCursor];
	} else if (dragging && point.x > splitterRect.origin.x+splitterRect.size.width) {
		return [NSCursor resizeRightCursor];
	} else if (dragging || CGRectContainsPoint(splitterRect, point)) {
		return [NSCursor resizeLeftRightCursor];
	} else {
		return [super mouseCursorForEvent:event];
	}
}

@end



@implementation UISplitViewController
@synthesize delegate=_delegate, viewControllers=_viewControllers;

- (id)initWithNibName:(NSString *)nibName bundle:(NSBundle *)nibBundle
{
	if ((self=[super initWithNibName:nibName bundle:nibBundle])) {
	}
	return self;
}

- (void)dealloc
{
	[_viewControllers release];
	[super dealloc];
}

- (void)loadView
{
	self.view = [[[_UISplitViewControllerView alloc] initWithSplitViewController:self] autorelease];
	self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
}

- (void)setViewControllers:(NSArray *)newControllers
{
	NSAssert(([newControllers count]==2), nil);
	
	if (![newControllers isEqualToArray:_viewControllers]) {
		for (UIViewController *c in _viewControllers) {
			[c.view removeFromSuperview];
		}
		
		[_viewControllers release];
		_viewControllers = [newControllers copy];
		
		for (UIViewController *c in _viewControllers) {
			[self.view addSubview:c.view];
		}
	}
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	for (UIViewController *c in _viewControllers) {
		[c viewWillAppear:animated];
	}
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	for (UIViewController *c in _viewControllers) {
		[c viewDidAppear:animated];
	}
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
	for (UIViewController *c in _viewControllers) {
		[c viewWillDisappear:animated];
	}
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
	for (UIViewController *c in _viewControllers) {
		[c viewDidDisappear:animated];
	}
}

@end
