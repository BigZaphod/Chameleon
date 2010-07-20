//  Created by Sean Heber on 6/19/10.
#import <AppKit/NSGraphics.h>
#import <Foundation/Foundation.h>

@class NSImage;

NSCompositingOperation _NSCompositingOperationFromCGBlendMode(CGBlendMode blendMode);
NSImage *_NSImageCreateSubimage(NSImage *theImage, CGRect rect);
