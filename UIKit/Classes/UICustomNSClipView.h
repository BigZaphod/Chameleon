//  Created by Sean Heber on 8/26/10.
#import <AppKit/NSClipView.h>

@class CALayer;

@interface UICustomNSClipView : NSClipView {
	CALayer *parentLayer;
}

// This will attempt to force the UICustomNSClipView's layer to always remain attached to the given parent layer.
// Circumventing AppKit for fun and profit!
- (void)setLayerParent:(CALayer *)layer;

@end
