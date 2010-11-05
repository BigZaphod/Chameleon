//  Created by Sean Heber on 6/25/10.
#import "UIToolbar.h"
#import "UIBarButtonItem.h"
#import "UIToolbarButton.h"
#import "UIColor.h"
#import "UIGraphics.h"

@implementation UIToolbar
@synthesize barStyle=_barStyle, tintColor=_tintColor, items=_items, translucent=_translucent;

- (id)init
{
	return [self initWithFrame:CGRectMake(0,0,320,32)];
}

- (id)initWithFrame:(CGRect)frame
{
	if ((self=[super initWithFrame:frame])) {
		_items = [[NSMutableArray alloc] init];
		_itemViews = [[NSMutableArray alloc] init];
		self.barStyle = UIBarStyleDefault;
		self.translucent = NO;
		self.tintColor = nil;
	}
	return self;
}

- (void)dealloc
{
	[_tintColor release];
	[_items release];
	[_itemViews release];
	[super dealloc];
}

- (void)setBarStyle:(UIBarStyle)newStyle
{
	_barStyle = newStyle;

	// this is for backward compatibility - UIBarStyleBlackTranslucent is deprecated 
	if (_barStyle == UIBarStyleBlackTranslucent) {
		self.translucent = YES;
	}
}

- (void)_updateItemViews
{
	[_itemViews makeObjectsPerformSelector:@selector(removeFromSuperview)];
	[_itemViews removeAllObjects];

	NSUInteger numberOfFlexibleItems = 0;
	
	for (UIBarButtonItem *item in _items) {
		if ((item->_isSystemItem) && (item->_systemItem == UIBarButtonSystemItemFlexibleSpace)) {
			numberOfFlexibleItems++;
		}
	}

	const CGSize size = self.bounds.size;
	const CGFloat flexibleSpaceWidth = (numberOfFlexibleItems > 0)? MAX(0, size.width/numberOfFlexibleItems) : 0;
	CGFloat left = 0;
	
	for (UIBarButtonItem *item in _items) {
		UIView *view = item.customView;

		if (!view) {
			if (item->_isSystemItem && item->_systemItem == UIBarButtonSystemItemFlexibleSpace) {
				left += flexibleSpaceWidth;
			} else if (item->_isSystemItem && item->_systemItem == UIBarButtonSystemItemFixedSpace) {
				left += item.width;
			} else {
				view = [[[UIToolbarButton alloc] initWithBarButtonItem:item] autorelease];
			}
		}
		
		if (view) {
			CGRect frame = view.frame;
			frame.origin.x = left;
			frame.origin.y = (size.height / 2.f) - (frame.size.height / 2.f);
			frame = CGRectStandardize(frame);
			
			view.frame = frame;
			left += frame.size.width;
			
			[self addSubview:view];
		}
	}
}

- (void)setItems:(NSArray *)newItems animated:(BOOL)animated
{
	if (![_items isEqualToArray:newItems]) {

		// if animated, fade old item views out, otherwise just remove them
		if (animated) {
			for (UIView *v in _itemViews) {
				[UIView beginAnimations:@"fadeOut" context:NULL];
				[UIView setAnimationDidStopSelector:@selector(removeFromSuperview)];
				[UIView setAnimationDelegate:v];
				v.alpha = 0;
				[UIView commitAnimations];
			}
			[_itemViews removeAllObjects];
		}

		[_items setArray:newItems];
		[self _updateItemViews];

		// if animated, fade them in
		if (animated) {
			for (UIView *v in _itemViews) v.alpha = 0;
			[UIView beginAnimations:@"fadeIn" context:NULL];
			for (UIView *v in _itemViews) v.alpha = 1;
			[UIView commitAnimations];
		}
	}
}

- (void)setItems:(NSArray *)items
{
	[self setItems:items animated:NO];
}

- (NSArray *)items
{
	return [[_items copy] autorelease];
}

- (void)drawRect:(CGRect)rect
{
	const CGRect bounds = self.bounds;
	
	// I kind of suspect that the "right" thing to do is to draw the background and then paint over it with the tintColor doing some kind of blending
	// so that it actually doesn "tint" the image instead of define it. That'd probably work better with the bottom line coloring and stuff, too, but
	// for now hardcoding stuff works well enough.
	
	UIColor *color = _tintColor ?: [UIColor colorWithRed:21/255.f green:21/255.f blue:25/255.f alpha:1];

	[color setFill];
	UIRectFill(bounds);
	
	[[UIColor blackColor] setFill];
	UIRectFill(CGRectMake(0,0,bounds.size.width,1));
}

@end
