//  Created by Sean Heber on 5/27/10.
#import "UIApplication.h"
#import "UIWindow.h"
#import "UIResponder.h"
#import "UIEvent.h"
#import "UITouch.h"
#import "UIScreen.h"
#import "UITableViewCell.h"
#import "UIImage.h"
#import "UIControl.h"
#import "UIFont.h"
#import "UIColor.h"

@class NSColor, NSFont, NSImage, UIViewController;

@interface UIApplication (Private)
- (void)_setKeyWindow:(UIWindow *)newKeyWindow;
- (void)_windowDidBecomeVisible:(UIWindow *)theWindow;
- (void)_windowDidBecomeHidden:(UIWindow *)theWindow;
- (void)_screen:(UIScreen *)theScreen didReceiveNSEvent:(NSEvent *)theEvent;
@end

@interface UIWindow (Private)
- (void)_makeHidden;
- (void)_makeVisible;
- (UIResponder *)_firstResponder;
- (void)_setFirstResponder:(UIResponder *)newFirstResponder;
@end

@interface UIResponder (Private)
- (void)_scrollWheelMoved:(CGPoint)delta withEvent:(UIEvent *)event;
@end

@interface UIEvent (Private)
- (void)_setNSEvent:(NSEvent *)theEvent;
- (NSEvent *)_NSEvent;
- (void)_setTouch:(UITouch *)theTouch;
- (UITouch *)_touch;
@end

@interface UITouch (Private)
- (void)_updateWithNSEvent:(NSEvent *)theEvent screenLocation:(CGPoint)baseLocation;
- (void)_setView:(UIView *)theView;
@end

@interface UIView (Private)
- (void)_layoutSubviews;
- (void)_setViewController:(UIViewController *)theViewController;
- (void)_superviewSizeDidChangeFrom:(CGSize)oldSize to:(CGSize)newSize;
- (void)_boundsSizeDidChange;
- (void)_hierarchyPositionDidChange;
@end

@interface UIScreen (Private)
- (void)_setNSView:(NSView *)theView;
- (NSView *)_NSView;
- (CALayer *)_layer;
- (BOOL)_hasResizeIndicator;
@end

@interface UITableViewCell (Private)
- (void)_setSeparatorStyle:(UITableViewCellSeparatorStyle)theStyle color:(UIColor *)theColor;
@end

@interface UIImage (Private)
+ (UIImage *)_frameworkImageNamed:(NSString *)name;
- (id)_initWithNSImage:(NSImage *)theImage;
@end

@interface UIControl (Private)
- (void)_stateDidChange;
@end

@interface UIFont (Private)
- (NSFont *)_NSFont;
@end

@interface UIColor (Private)
- (NSColor *)_NSColor;
@end


extern const CGFloat _UIScrollViewScrollerSize;
