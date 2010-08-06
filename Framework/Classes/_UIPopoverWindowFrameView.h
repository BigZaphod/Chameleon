//
//  PopoverWindowFrameView.h
//  Ostrich
//
//  Created by Craig Hockenberry on 7/26/10.
//  Copyright 2010 The Iconfactory. All rights reserved.
//

#import <Cocoa/Cocoa.h>

typedef enum
{
	_UIPopoverWindowFrameEdgeLeft = 0,
	_UIPopoverWindowFrameEdgeRight,
	_UIPopoverWindowFrameEdgeTop,
	_UIPopoverWindowFrameEdgeBottom,
} _UIPopoverWindowFrameEdge;

@interface _UIPopoverWindowFrameView : NSView
{
	NSPoint point;
	_UIPopoverWindowFrameEdge edge;
}

@property (nonatomic, assign) NSPoint point;
@property (nonatomic, assign) _UIPopoverWindowFrameEdge edge;

@end
