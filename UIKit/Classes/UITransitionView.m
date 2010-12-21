//  Created by Sean Heber on 11/12/10.
#import "UITransitionView.h"

@implementation UITransitionView
@synthesize view=_view, transition=_transition, delegate=_delegate;

- (id)initWithFrame:(CGRect)frame view:(UIView *)aView
{
	if ((self=[super initWithFrame:frame])) {
		self.view = aView;
	}
	return self;
}

- (void)dealloc
{
	[_view release];
	[super dealloc];
}

- (void)setFrame:(CGRect)frame
{
	[super setFrame:frame];
	_view.frame = self.bounds;
}

- (CGRect)_rectForIncomingView
{
	switch (_transition) {
		case UITransitionPushRight:
		case UITransitionFromLeft:		return CGRectOffset(self.bounds,-self.bounds.size.width,0);
		case UITransitionPushLeft:
		case UITransitionFromRight:		return CGRectOffset(self.bounds,self.bounds.size.width,0);
		case UITransitionPushDown:
		case UITransitionFromTop:		return CGRectOffset(self.bounds,0,-self.bounds.size.height);
		case UITransitionPushUp:
		case UITransitionFromBottom:	return CGRectOffset(self.bounds,0,self.bounds.size.height);
		default:						return self.bounds;
	}
}

- (CGRect)_rectForOutgoingView
{
	switch (_transition) {
		case UITransitionPushLeft:		return CGRectOffset(self.bounds,-self.bounds.size.width,0);
		case UITransitionPushRight:		return CGRectOffset(self.bounds,self.bounds.size.width,0);
		case UITransitionPushDown:		return CGRectOffset(self.bounds,0,self.bounds.size.height);
		case UITransitionPushUp:		return CGRectOffset(self.bounds,0,-self.bounds.size.height);
		default:						return self.bounds;
	}
}

- (void)_finishTransition:(NSDictionary *)info
{
	UIView *fromView = [info objectForKey:@"fromView"];
	UIView *toView = [info objectForKey:@"toView"];
	UITransition transition = [[info objectForKey:@"transition"] intValue];
	
	[fromView removeFromSuperview];

	[_delegate transitionView:self didTransitionFromView:fromView toView:toView withTransition:transition];
}

- (void)_animation:(NSString *)name didFinish:(NSNumber *)finished info:(NSDictionary *)info
{
	[self _finishTransition:info];
	[info release];
}

- (void)setView:(UIView *)aView
{
	if (aView != _view) {
		aView.frame = [self _rectForIncomingView];
		[self addSubview:aView];
		
		NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:
							  _view, @"fromView",
							  aView, @"toView",
							  [NSNumber numberWithInt:_transition], @"transition",
							  nil];
		
		if (_transition == UITransitionNone) {
			[self _finishTransition:info];
		} else {
			if (_transition == UITransitionFadeOut) {
				[self sendSubviewToBack:aView];
			} else if (_transition == UITransitionFadeIn) {
				aView.alpha = 0;
			}
			
			[UIView beginAnimations:@"UITransitionView" context:(void *)[info retain]];
			[UIView setAnimationDidStopSelector:@selector(_animation:didFinish:info:)];
			[UIView setAnimationDelegate:self];
			[UIView setAnimationDuration:0.33];
			
			_view.frame = [self _rectForOutgoingView];
			aView.frame = self.bounds;
			
			if (_transition == UITransitionFadeOut || _transition == UITransitionCrossFade) {
				_view.alpha = 0;
			}
			
			if (_transition == UITransitionFadeIn || _transition == UITransitionCrossFade) {
				aView.alpha = 1;
			}
			
			[UIView commitAnimations];
		}
		
		[_view release];
		_view = [aView retain];
	}
}

@end
