#import "MyWindow.h"
#import "MyTitleBarViewController.h"

@implementation MyWindow

@synthesize constrainingToScreenSuspended;

// This window has its usual -constrainFrameRect:toScreen: behavior temporarily suppressed.
// This enables our window's custom Full Screen Exit animations to avoid being constrained by the
// top edge of the screen and the menu bar.
//
- (instancetype)initWithContentRect:(NSRect)contentRect styleMask:(NSUInteger)aStyle backing:(NSBackingStoreType)bufferingType defer:(BOOL)flag {
    if (self = [super initWithContentRect:contentRect styleMask:aStyle backing:bufferingType defer:flag]) {
        [self customTitleBar];
    }
    return self;
}

- (instancetype)initWithContentRect:(NSRect)contentRect styleMask:(NSUInteger)aStyle backing:(NSBackingStoreType)bufferingType defer:(BOOL)flag screen:(NSScreen *)screen {
    if (self = [super initWithContentRect:contentRect styleMask:aStyle backing:bufferingType defer:flag screen:screen]) {
        [self customTitleBar];
    }
    return self;
}

- (void)customTitleBar {
    self.titleVisibility = NSWindowTitleHidden;
    self.titlebarAppearsTransparent = YES;
    
    MyTitleBarViewController *vc = [[MyTitleBarViewController alloc] initWithNibName:@"MyTitleBarViewController" bundle:NULL];
    [self addTitlebarAccessoryViewController:vc];
    self.titleBarVc = vc;
    [vc release];
}

- (NSRect)constrainFrameRect:(NSRect)frameRect toScreen:(NSScreen *)screen {
    if (constrainingToScreenSuspended) {
        return frameRect;
    }
    else {
        return [super constrainFrameRect:frameRect toScreen:screen];
    }
}

- (CGFloat)toolbarHeight {
    return 100.0f;
}

- (CGFloat)minimumTitlebarHeight {
    static CGFloat minTitleHeight = 0.0;
    if (!minTitleHeight) {
        NSRect frameRect = self.frame;
        NSRect contentRect = [self contentRectForFrameRect:frameRect];
        minTitleHeight = NSHeight(frameRect) - NSHeight(contentRect);
    }
    return minTitleHeight;
}

@end
