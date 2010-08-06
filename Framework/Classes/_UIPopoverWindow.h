//
//  PopoverWindow.h
//  Ostrich
//
//  Created by Craig Hockenberry on 7/26/10.
//  Copyright 2010 The Iconfactory. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface _UIPopoverWindow : NSWindow
{
	NSView *childContentView;
	NSButton *closeButton;
}

- (void)setFrameForContentSize:(NSSize)size atPoint:(NSPoint)point inWindow:(NSWindow *)window;

@end
