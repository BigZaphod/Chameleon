//  Created by Sean Heber on 6/1/10.
#import <QuartzCore/QuartzCore.h>

// This exists as a way to patch into CALayer so that a UIView can disable autoresizing of subviews.
// There might be some better way to do this using constraints on the layer or the layout manager or
// something.. but this works for now, I suppose.

@interface CALayer (UIKit)
- (void)UIKitResizeSublayersWithOldSize:(CGSize)size;
//+ (CALayer *)UIKitCommonParentForLayers:(NSArray *)layers;
@end
