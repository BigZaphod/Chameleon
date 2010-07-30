//  Created by Sean Heber on 5/27/10.
#import "UIApplication.h"
#import "UIWindow.h"
#import "UIEvent.h"
#import "UITouch.h"
#import "UIScreen.h"
#import "UITableViewCell.h"
#import "UIImage.h"
#import "UIControl.h"
#import "UIFont.h"
#import "UIColor.h"
#import "UIViewController.h"

@class NSColor, NSFont, NSImage;

@interface UIApplication (_Private)
- (void)_setKeyWindow:(UIWindow *)newKeyWindow;
- (void)_windowDidBecomeVisible:(UIWindow *)theWindow;
- (void)_windowDidBecomeHidden:(UIWindow *)theWindow;
- (void)_screen:(UIScreen *)theScreen didReceiveNSEvent:(NSEvent *)theEvent;
@end

@interface UIWindow (_Private)
- (void)_makeHidden;
- (void)_makeVisible;
- (UIResponder *)_firstResponder;
- (void)_setFirstResponder:(UIResponder *)newFirstResponder;
@end

@interface UIEvent (_Private)
- (void)_setNSEvent:(NSEvent *)theEvent;
- (NSEvent *)_NSEvent;
- (void)_setTouch:(UITouch *)theTouch;
- (UITouch *)_touch;
@end

@interface UITouch (_Private)
- (void)_updateWithNSEvent:(NSEvent *)theEvent screenLocation:(CGPoint)baseLocation;
- (void)_setView:(UIView *)theView;
@end

@interface UIView (_Private)
- (void)_layoutSubviews;
- (void)_setViewController:(UIViewController *)theViewController;
- (void)_superviewSizeDidChangeFrom:(CGSize)oldSize to:(CGSize)newSize;
- (void)_boundsSizeDidChange;
- (void)_hierarchyPositionDidChange;
@end

@interface UIScreen (_Private)
- (void)_setNSView:(NSView *)theView;
- (NSView *)_NSView;
- (CALayer *)_layer;
- (BOOL)_hasResizeIndicator;
@end

@interface UITableViewCell (_Private)
- (void)_setSeparatorStyle:(UITableViewCellSeparatorStyle)theStyle color:(UIColor *)theColor;
@end

@interface UIImage (_Private)
+ (UIImage *)_frameworkImageNamed:(NSString *)name;
- (id)_initWithNSImage:(NSImage *)theImage;
@end

@interface UIControl (_Private)
- (void)_stateDidChange;
@end

@interface UIFont (_Private)
- (NSFont *)_NSFont;
@end

@interface UIColor (_Private)
- (NSColor *)_NSColor;
@end

@interface UIViewController (_Private)
- (void)_setNavigationController:(UINavigationController *)navController;
@end


extern const CGFloat _UIScrollViewScrollerSize;
