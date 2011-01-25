//  Created by Sean Heber on 6/29/10.
#import "UIGestureRecognizer.h"
#import "UIGestureRecognizerSubclass.h"

@implementation UIGestureRecognizer
@synthesize delegate=_delegate, delaysTouchesBegan=_delaysTouchesBegan, delaysTouchesEnded=_delaysTouchesEnded, cancelsTouchesInView=_cancelsTouchesInView;
@synthesize state=_state, enabled=_enabled, view=_view;

- (id)initWithTarget:(id)target action:(SEL)action
{
	if ((self=[super init])) {
		_state = UIGestureRecognizerStatePossible;
		_cancelsTouchesInView = YES;
		_delaysTouchesBegan = NO;
		_delaysTouchesEnded = YES;
		_enabled = YES;

		[self addTarget:target action:action];
	}
	return self;
}

- (void)dealloc
{
	[super dealloc];
}

- (void)_setView:(UIView *)v
{
	_view = v;
}

- (void)setDelegate:(id<UIGestureRecognizerDelegate>)aDelegate
{
	if (aDelegate != _delegate) {
		_delegate = aDelegate;
		_delegateHas.shouldBegin = [_delegate respondsToSelector:@selector(gestureRecognizerShouldBegin:)];
		_delegateHas.shouldReceiveTouch = [_delegate respondsToSelector:@selector(gestureRecognizer:shouldReceiveTouch:)];
		_delegateHas.shouldRecognizeSimultaneouslyWithGestureRecognizer = [_delegate respondsToSelector:@selector(gestureRecognizer:shouldRecognizeSimultaneouslyWithGestureRecognizer:)];
	}
}

- (void)addTarget:(id)target action:(SEL)action
{
	NSAssert(target != nil, nil);
	NSAssert(action != NULL, nil);
}

- (void)removeTarget:(id)target action:(SEL)action
{
}

- (void)requireGestureRecognizerToFail:(UIGestureRecognizer *)otherGestureRecognizer
{
}

- (CGPoint)locationInView:(UIView *)view
{
	return CGPointZero;
}

- (void)setState:(UIGestureRecognizerState)state
{
	if (state != _state) {

		// the docs didn't say explicitly if these state transitions were verified, but I suspect they are. if anything, a check like this
		// should help debug things. it also helps me better understand the whole thing, so it's not a total waste of time :)

		typedef struct { UIGestureRecognizerState fromState, toState; } StateTransition;

		#define UIGestureRecognizerStateTransitions 11
		static const StateTransition allowedTransitions[UIGestureRecognizerStateTransitions] = {
			// discrete gestures
			{UIGestureRecognizerStatePossible,	UIGestureRecognizerStateRecognized},
			{UIGestureRecognizerStatePossible,	UIGestureRecognizerStateFailed},
			{UIGestureRecognizerStateFailed,	UIGestureRecognizerStatePossible},
			{UIGestureRecognizerStatePossible,	UIGestureRecognizerStateBegan},
			// continuous gestures
			{UIGestureRecognizerStateBegan,		UIGestureRecognizerStateChanged},
			{UIGestureRecognizerStateBegan,		UIGestureRecognizerStateCancelled},
			{UIGestureRecognizerStateBegan,		UIGestureRecognizerStateEnded},
			{UIGestureRecognizerStateChanged,	UIGestureRecognizerStateCancelled},
			{UIGestureRecognizerStateChanged,	UIGestureRecognizerStateEnded},
			{UIGestureRecognizerStateCancelled,	UIGestureRecognizerStatePossible},
			{UIGestureRecognizerStateEnded,		UIGestureRecognizerStatePossible}
		};
		
		BOOL isValidStateTransition = NO;
		
		for (NSUInteger t=0; t<UIGestureRecognizerStateTransitions; t++) {
			if (allowedTransitions[t].fromState == _state && allowedTransitions[t].toState == state) {
				isValidStateTransition = YES;
				break;
			}
		}

		NSAssert(isValidStateTransition, nil);

		_state = state;
			
		// probably do stuff here like send messages if we're in the right state now.
	}
}

- (void)reset
{
}

- (BOOL)canPreventGestureRecognizer:(UIGestureRecognizer *)preventedGestureRecognizer
{
	return YES;
}

- (BOOL)canBePreventedByGestureRecognizer:(UIGestureRecognizer *)preventingGestureRecognizer
{
	return YES;
}

- (void)ignoreTouch:(UITouch*)touch forEvent:(UIEvent*)event
{
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
}

@end
