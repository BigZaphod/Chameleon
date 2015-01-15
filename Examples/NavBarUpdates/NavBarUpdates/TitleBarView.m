//
//  TitleBarView.m
//  FullScreenWindow
//
//  Created by bobo on 11/7/14.
//  Copyright (c) 2014 Apple. All rights reserved.
//

#import "TitleBarView.h"





NS_INLINE bool INRunningLion() {
    return (NSInteger)NSAppKitVersionNumber >= NSAppKitVersionNumber10_7;
}

@implementation TitleBarView

- (void)drawRect:(NSRect)dirtyRect
{
//    [[NSColor colorWithDeviceRed:22.0f/255.0f green:188.0f/255.0f blue:92.0f/255.0f alpha:1.0] set];
    [[NSColor clearColor] set];
    NSRectFill(dirtyRect);
}
@end

@implementation TitleBackGroudView

- (void)drawRect:(NSRect)dirtyRect
{
    [[NSColor colorWithDeviceRed:22.0f/255.0f green:188.0f/255.0f blue:92.0f/255.0f alpha:1.0] set];
//    [[NSColor redColor] set];
    NSRectFill(dirtyRect);
}

@end
