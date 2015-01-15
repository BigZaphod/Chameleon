/*
     File: MyWindow.m 
 Abstract: NSWindow subclass for overriding "constrainFrameRect".
  
  Version: 1.1 
  
 Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple 
 Inc. ("Apple") in consideration of your agreement to the following 
 terms, and your use, installation, modification or redistribution of 
 this Apple software constitutes acceptance of these terms.  If you do 
 not agree with these terms, please do not use, install, modify or 
 redistribute this Apple software. 
  
 In consideration of your agreement to abide by the following terms, and 
 subject to these terms, Apple grants you a personal, non-exclusive 
 license, under Apple's copyrights in this original Apple software (the 
 "Apple Software"), to use, reproduce, modify and redistribute the Apple 
 Software, with or without modifications, in source and/or binary forms; 
 provided that if you redistribute the Apple Software in its entirety and 
 without modifications, you must retain this notice and the following 
 text and disclaimers in all such redistributions of the Apple Software. 
 Neither the name, trademarks, service marks or logos of Apple Inc. may 
 be used to endorse or promote products derived from the Apple Software 
 without specific prior written permission from Apple.  Except as 
 expressly stated in this notice, no other rights or licenses, express or 
 implied, are granted by Apple herein, including but not limited to any 
 patent rights that may be infringed by your derivative works or by other 
 works in which the Apple Software may be incorporated. 
  
 The Apple Software is provided by Apple on an "AS IS" basis.  APPLE 
 MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION 
 THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS 
 FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND 
 OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS. 
  
 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL 
 OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF 
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS 
 INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION, 
 MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED 
 AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE), 
 STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE 
 POSSIBILITY OF SUCH DAMAGE. 
  
 Copyright (C) 2012 Apple Inc. All Rights Reserved. 
  
 */

#import "MyWindow.h"
#import "MyTitleBarViewController.h"

@implementation MyWindow

@synthesize constrainingToScreenSuspended;

// This window has its usual -constrainFrameRect:toScreen: behavior temporarily suppressed.
// This enables our window's custom Full Screen Exit animations to avoid being constrained by the
// top edge of the screen and the menu bar.
//
- (instancetype)initWithContentRect:(NSRect)contentRect styleMask:(NSUInteger)aStyle backing:(NSBackingStoreType)bufferingType defer:(BOOL)flag
{
    if(self = [super initWithContentRect:contentRect styleMask:aStyle backing:bufferingType defer:flag])
    {
        [self customTitleBar];
    }
    return self;
}

- (instancetype)initWithContentRect:(NSRect)contentRect styleMask:(NSUInteger)aStyle backing:(NSBackingStoreType)bufferingType defer:(BOOL)flag screen:(NSScreen *)screen
{
    if(self = [super initWithContentRect:contentRect styleMask:aStyle backing:bufferingType defer:flag screen:screen])
    {
        [self customTitleBar];
    }
    return self;
}

- (void)customTitleBar
{
    self.titleVisibility = NSWindowTitleHidden;
    self.titlebarAppearsTransparent = YES;
//    self.backgroundColor = [NSColor orangeColor];
    
//    [self setStyleMask:NSFullSizeContentViewWindowMask];
    MyTitleBarViewController *vc = [[MyTitleBarViewController alloc] initWithNibName:@"MyTitleBarViewController" bundle:NULL];
    [self addTitlebarAccessoryViewController:vc];
    self.titleBarVc = vc;
    [vc release];
}

- (NSRect)constrainFrameRect:(NSRect)frameRect toScreen:(NSScreen *)screen
{
    if (constrainingToScreenSuspended)
    {
        return frameRect;
    }
    else
    {
        return [super constrainFrameRect:frameRect toScreen:screen];
    }
}

- (CGFloat)toolbarHeight
{
    return 100.0f;
}


- (CGFloat)minimumTitlebarHeight
{
    static CGFloat minTitleHeight = 0.0;
    if (!minTitleHeight) {
        NSRect frameRect = self.frame;
        NSRect contentRect = [self contentRectForFrameRect:frameRect];
        minTitleHeight = NSHeight(frameRect) - NSHeight(contentRect);
    }
    return minTitleHeight;
}
@end
