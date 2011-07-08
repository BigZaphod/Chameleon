#import "UIViewAppKitIntegration.h"


@implementation UIView (AppKitIntegration)

- (UIView*) nextKeyView
{
    return _nextKeyView;
}

- (UIView*) previousKeyView
{
    return _previousKeyView;
}

- (void) _setPreviousKeyView:(UIView*)previousKeyView
{
    _previousKeyView = previousKeyView;
}

- (void) setNextKeyView:(UIView*)nextKeyView
{
    _nextKeyView = nextKeyView;
    [nextKeyView _setPreviousKeyView:self];
}

- (UIView*) nextValidKeyView
{
    UIView* next = [self nextKeyView];
    while (next && next != self && ![next canBecomeFirstResponder]) {
        next = [next nextKeyView];
    }
    return next;
}

- (UIView*) previousValidKeyView
{
    UIView* prev = [self previousKeyView];
    while (prev && prev != self && ![prev canBecomeFirstResponder]) {
        prev = [prev previousKeyView];
    }
    return prev;
}

@end
