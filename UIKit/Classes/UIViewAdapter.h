//  Created by Sean Heber on 12/1/10.
#import "UIScrollView.h"

@class NSView, UINSClipView;

@interface UIViewAdapter : UIScrollView {
@private
	UINSClipView *_clipView;
	NSView *_view;
}

- (id)initWithNSView:(NSView *)aNSView;

@property (nonatomic, retain) NSView *NSView;

@end
