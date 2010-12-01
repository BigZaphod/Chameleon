//  Created by Sean Heber on 12/1/10.
#import <AppKit/NSClipView.h>

@class UIScrollView;

@interface UINSClipView : NSClipView {
	UIScrollView *parentView;
}

- (id)initWithFrame:(NSRect)frame parentView:(UIScrollView *)aView;

@end
