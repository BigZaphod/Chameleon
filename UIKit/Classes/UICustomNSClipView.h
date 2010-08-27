//  Created by Sean Heber on 8/26/10.
#import <AppKit/NSClipView.h>

@class CALayer;

@protocol UICustomNSClipViewDelegate
// the point should be in the clip view's superview coordinate space - aka the "screen" coordinate space because if everything
// is being done correctly, this view is never nested inside any other kind of NSView.
- (BOOL)hitTestForClipViewPoint:(NSPoint)point;
@end

@interface UICustomNSClipView : NSClipView {
	CALayer *parentLayer;
	id<UICustomNSClipViewDelegate> hitDelegate;
}

// A layer parent is just a layer that UICustonNSClipView will attempt to always remain a sublayer of.
// Circumventing AppKit for fun and profit!
// The hitDelegate is for faking out the NSView's usual hitTest: checks to handle cases where UIViews are above
// the UIView that's displaying this layer.
- (id)initWithFrame:(NSRect)frame layerParent:(CALayer *)layer hitDelegate:(id<UICustomNSClipViewDelegate>)theDelegate;

@end
