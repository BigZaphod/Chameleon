//
// UIThreePartImage.m
//
// Original Author:
//  The IconFactory
//
// Contributor: 
//	Zac Bowling <zac@seatme.com>
//
// Copyright (C) 2011 SeatMe, Inc http://www.seatme.com
//
// Permission is hereby granted, free of charge, to any person obtaining
// a copy of this software and associated documentation files (the
// "Software"), to deal in the Software without restriction, including
// without limitation the rights to use, copy, modify, merge, publish,
// distribute, sublicense, and/or sell copies of the Software, and to
// permit persons to whom the Software is furnished to do so, subject to
// the following conditions:
// 
// The above copyright notice and this permission notice shall be
// included in all copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
// EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
// MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
// NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
// LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
// OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
// WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//
/*
 * Copyright (c) 2011, The Iconfactory. All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 *
 * 2. Redistributions in binary form must reproduce the above copyright notice,
 *    this list of conditions and the following disclaimer in the documentation
 *    and/or other materials provided with the distribution.
 *
 * 3. Neither the name of The Iconfactory nor the names of its contributors may
 *    be used to endorse or promote products derived from this software without
 *    specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 * ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 * WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE ICONFACTORY BE LIABLE FOR ANY DIRECT,
 * INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
 * BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
 * LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
 * OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
 * ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import "UIThreePartImage.h"
#import "UIGraphics.h"

@implementation UIThreePartImage

- (id)initWithCGImage:(CGImageRef)theImage capSize:(NSInteger)capSize vertical:(BOOL)isVertical
{
    if ((self=[super initWithCGImage:theImage])) {
        const CGSize size = self.size;

        _vertical = isVertical;
        
        if (_vertical) {
            const CGFloat stretchyHeight = (capSize < size.height)? 1 : 0;
            const CGFloat bottomCapHeight = size.height - capSize - stretchyHeight;
            
            _capInsets = UIEdgeInsetsMake(0, capSize, 0, capSize);

            _startCap = CGImageCreateWithImageInRect(theImage, CGRectMake(0,0,size.width,capSize));
            _centerFill = CGImageCreateWithImageInRect(theImage, CGRectMake(0,capSize,size.width,stretchyHeight));
            _endCap = CGImageCreateWithImageInRect(theImage, CGRectMake(0,size.height-bottomCapHeight,size.width,bottomCapHeight));
        } else {
            const CGFloat stretchyWidth = (capSize < size.width)? 1 : 0;
            const CGFloat rightCapWidth = size.width - capSize - stretchyWidth;
            _capInsets = UIEdgeInsetsMake(capSize, 0, capSize, 0);

            _startCap = CGImageCreateWithImageInRect(theImage, CGRectMake(0,0,capSize,size.height));
            _centerFill = CGImageCreateWithImageInRect(theImage, CGRectMake(capSize,0,stretchyWidth,size.height));
            _endCap = CGImageCreateWithImageInRect(theImage, CGRectMake(size.width-rightCapWidth,0,rightCapWidth,size.height));

        }
    }
    return self;
}

- (id)initWithCGImage:(CGImageRef)theImage capLeft:(CGFloat)capLeft capRight:(CGFloat)capRight 
{
    if ((self=[super initWithCGImage:theImage])) {
        const CGSize size = self.size;
        
        _vertical = NO;
        
        const CGFloat stretchyWidth = size.width - capRight - capLeft;
        
        _capInsets = UIEdgeInsetsMake(0, capLeft, 0, capRight);
        
        _startCap = CGImageCreateWithImageInRect(theImage, CGRectMake(0,0,capLeft,size.height));
        _centerFill = CGImageCreateWithImageInRect(theImage, CGRectMake(capLeft,0,stretchyWidth,size.height));
        _endCap = CGImageCreateWithImageInRect(theImage, CGRectMake(size.width-capRight,0,capRight,size.height));
    }
    return self;
}

- (id)initWithCGImage:(CGImageRef)theImage capTop:(CGFloat)capTop capBottom:(CGFloat)capBottom 
{
    if ((self=[super initWithCGImage:theImage])) {
        const CGSize size = self.size;
        
        _vertical = YES;
        
        const CGFloat stretchyHeight = size.height - capTop - capBottom;
        
        _capInsets = UIEdgeInsetsMake(capTop,0, capBottom, 0);
        
        _startCap = CGImageCreateWithImageInRect(theImage, CGRectMake(0,0,size.width,capTop));
        _centerFill = CGImageCreateWithImageInRect(theImage, CGRectMake(0,capTop,size.width,stretchyHeight));
        _endCap = CGImageCreateWithImageInRect(theImage, CGRectMake(0,size.height-capBottom,size.width,capBottom));
    }
    return self;
}


- (void)dealloc
{
    if (_startCap)
        CGImageRelease(_startCap);
    if (_centerFill)
        CGImageRelease(_centerFill);
    if (_endCap)
        CGImageRelease(_endCap);
    [super dealloc];
}

- (NSInteger)leftCapWidth
{
    return _vertical? 0 : CGImageGetWidth(_startCap);
}

- (NSInteger)topCapHeight
{
    return _vertical ? CGImageGetHeight(_startCap) : 0;
}

- (UIEdgeInsets)capInsets 
{
    return _capInsets;
}

- (void)drawInRect:(CGRect)rect
{
    CGRect startCapRect = CGRectMake(rect.origin.x, rect.origin.y, _vertical ? rect.size.width : CGImageGetWidth(_startCap), _vertical ? CGImageGetHeight(_startCap) : rect.size.height);
    CGSize endCapSize = CGSizeMake(CGImageGetWidth(_endCap), CGImageGetHeight(_endCap));
    CGRect endCapRect = _vertical ? CGRectMake(rect.origin.x, CGRectGetMaxY(rect) - endCapSize.height, rect.size.width, endCapSize.height) : CGRectMake(CGRectGetMaxX(rect) - endCapSize.width, rect.origin.y, endCapSize.width, rect.size.height);
    CGRect centerFillRect = _vertical ? CGRectMake(rect.origin.x, CGRectGetMaxY(startCapRect), rect.size.width, rect.size.height - (startCapRect.size.height + endCapRect.size.height)) : CGRectMake(CGRectGetMaxX(startCapRect), rect.origin.y, rect.size.width - (startCapRect.size.width + endCapRect.size.width), rect.size.height);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSaveGState(ctx);
	CGContextScaleCTM(ctx, 1, -1);
	CGContextTranslateCTM(ctx, 0, -rect.size.height);
    CGContextDrawImage(ctx, startCapRect, _startCap);
    CGContextDrawImage(ctx, endCapRect, _endCap);
    CGContextClipToRect(ctx, centerFillRect); // bug in CGContextDrawTiledImage, has to be clipped before drawing
    CGContextDrawTiledImage(ctx, centerFillRect, _centerFill);
    CGContextRestoreGState(ctx);
}

@end
