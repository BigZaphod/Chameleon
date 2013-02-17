//
//  DDQuickMenuStatusItemView.m
//  IOSandMac_NoXib
//
//  Created by Dominik Pich on 16.02.13.
//  Copyright (c) 2013 Dominik Pich. All rights reserved.
//

#import "DDQuickMenuStatusItemView.h"

@implementation DDQuickMenuStatusItemView

- (NSImage*)currentImage {
    return self.isHighlighted ? self.item.alternateImage ? self.item.alternateImage : self.item.image : self.item.image;
}

- (void)setHighlighted:(BOOL)highlighted {
	_highlighted = highlighted;
	self.needsDisplay = YES;
}

- (void)drawRect:(NSRect)dirtyRect {
    NSImage *image = nil;
    NSString *title = nil;
	if(self.item) {
		[self.item drawStatusBarBackgroundInRect:self.bounds withHighlight:self.isHighlighted];
        image = self.currentImage;
        title = self.title;
    }
    
    if(image) {
        NSRect r = self.bounds;
        r.size = [image size];
        r = [self.class centerRect:r inRect:self.bounds];
        r = [self centerScanRect:r];
        [image drawInRect:r fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1];
    }

    if(title) {
        NSDictionary *attr = @{NSFontAttributeName: [NSFont systemFontOfSize:11]};
        NSRect r = self.bounds;
        r.size = [title sizeWithAttributes:attr];
        r = [self.class centerRect:r inRect:self.bounds];
        r = [self centerScanRect:r];
        [title drawInRect:r withAttributes:attr];
    }
}

- (void)mouseDown:(NSEvent *)theEvent {
    if(theEvent.modifierFlags & NSControlKeyMask)
        [self rightMouseDown:theEvent];
    else
        [self.item popUpStatusItemMenu:self.item.menu];
}

- (void)rightMouseDown:(NSEvent *)theEvent {
	[NSApp sendAction:self.action to:self.target from:self];
}

#pragma mark -

+ (CGRect)centerRect:(CGRect)rect inRect:(CGRect)inRect
{
	CGRect result = rect;
	result.origin.x = inRect.origin.x + (inRect.size.width - result.size.width)*0.5f;
	result.origin.y = inRect.origin.y + (inRect.size.height - result.size.height)*0.5f;
	return result;
}

@end
