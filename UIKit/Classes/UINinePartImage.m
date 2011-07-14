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

#import "UINinePartImage.h"
#import "UIGraphics.h"

@implementation UINinePartImage

- (id)initWithCGImage:(CGImageRef)theImage leftCapWidth:(NSInteger)leftCapWidth topCapHeight:(NSInteger)topCapHeight
{
    if ((self=[super initWithCGImage:theImage])) {
        const CGSize size = self.size;
        const CGFloat stretchyWidth = (leftCapWidth < size.width)? 1 : 0;
        const CGFloat stretchyHeight = (topCapHeight < size.height)? 1 : 0;
        const CGFloat bottomCapHeight = size.height - topCapHeight - stretchyHeight;
        
        _topLeftCorner = CGImageCreateWithImageInRect(theImage, CGRectMake(0,0,leftCapWidth,topCapHeight));
        _topEdgeFill = CGImageCreateWithImageInRect(theImage, CGRectMake(leftCapWidth,0,stretchyWidth,topCapHeight));
        _topRightCorner = CGImageCreateWithImageInRect(theImage, CGRectMake(leftCapWidth+stretchyWidth,0,size.width-leftCapWidth-stretchyWidth,topCapHeight));
        
        _bottomLeftCorner = CGImageCreateWithImageInRect(theImage, CGRectMake(0,size.height-bottomCapHeight,leftCapWidth,bottomCapHeight));
        _bottomEdgeFill = CGImageCreateWithImageInRect(theImage, CGRectMake(leftCapWidth,size.height-bottomCapHeight,stretchyWidth,bottomCapHeight));
        _bottomRightCorner = CGImageCreateWithImageInRect(theImage, CGRectMake(leftCapWidth+stretchyWidth,size.height-bottomCapHeight,size.width-leftCapWidth-stretchyWidth,bottomCapHeight));

        _leftEdgeFill = CGImageCreateWithImageInRect(theImage, CGRectMake(0,topCapHeight,leftCapWidth,stretchyHeight));
        _centerFill = CGImageCreateWithImageInRect(theImage, CGRectMake(leftCapWidth,topCapHeight,stretchyWidth,stretchyHeight));
        _rightEdgeFill = CGImageCreateWithImageInRect(theImage, CGRectMake(leftCapWidth+stretchyWidth,topCapHeight,size.width-leftCapWidth-stretchyWidth,stretchyHeight));
    }
    return self;
}

- (void)dealloc
{
    if (_topLeftCorner)
        CGImageRelease(_topLeftCorner);
    if (_topEdgeFill) 
        CGImageRelease(_topEdgeFill);
    if (_topRightCorner)
        CGImageRelease(_topRightCorner);
    if (_leftEdgeFill)
        CGImageRelease(_leftEdgeFill);
    if (_centerFill) 
        CGImageRelease(_centerFill);
    if (_rightEdgeFill)
        CGImageRelease(_rightEdgeFill);
    if (_bottomLeftCorner) 
        CGImageRelease(_bottomLeftCorner);
    if (_bottomEdgeFill)
        CGImageRelease(_bottomEdgeFill);
    if (_bottomRightCorner) 
        CGImageRelease(_bottomRightCorner);
    [super dealloc];
}

- (NSInteger)leftCapWidth
{
    return CGImageGetWidth(_topLeftCorner);
}

- (NSInteger)topCapHeight
{
    return CGImageGetHeight(_topLeftCorner);
}

- (void)drawInRect:(CGRect)rect
{
    CGFloat topRightWidth = CGImageGetWidth(_topRightCorner);
    CGFloat bottomRightWidth = CGImageGetWidth(_bottomRightCorner);
    CGSize bottomLeftSize = CGSizeMake(CGImageGetWidth(_bottomLeftCorner), CGImageGetHeight(_bottomLeftCorner));
    CGRect topLeftRect = CGRectMake(rect.origin.x, rect.origin.y, CGImageGetWidth(_topLeftCorner), CGImageGetHeight(_topLeftCorner));
    CGRect topRightRect = CGRectMake(CGRectGetMaxX(rect) - topRightWidth, rect.origin.y, topRightWidth, topLeftRect.size.height);
    CGRect bottomLeftRect = CGRectMake(rect.origin.x, CGRectGetMaxY(rect) - bottomLeftSize.height, bottomLeftSize.width, bottomLeftSize.height);
    CGRect bottomRightRect = CGRectMake(CGRectGetMaxX(rect) - bottomRightWidth, bottomLeftRect.origin.y, bottomRightWidth, bottomLeftRect.size.height);
    CGRect topEdgeRect = CGRectMake(CGRectGetMaxX(topLeftRect), rect.origin.y, rect.size.width - (topLeftRect.size.width + topRightRect.size.width), topLeftRect.size.height);
    CGRect leftEdgeRect = CGRectMake(rect.origin.x, CGRectGetMaxY(topLeftRect), topLeftRect.size.width, rect.size.height - (topLeftRect.size.height + bottomLeftRect.size.height));
    CGRect bottomEdgeRect = CGRectMake(CGRectGetMaxX(bottomLeftRect), bottomLeftRect.origin.y, rect.size.width - (bottomLeftRect.size.width + bottomRightRect.size.width), bottomLeftRect.size.height);
    CGRect rightEdgeRect = CGRectMake(CGRectGetMaxX(rect) - topRightRect.size.width, CGRectGetMaxY(topRightRect), topRightRect.size.width, rect.size.height - (topRightRect.size.height + bottomRightRect.size.height));
    CGRect centerFillRect = CGRectMake(CGRectGetMaxX(topLeftRect), CGRectGetMaxY(topLeftRect), rect.size.width - (leftEdgeRect.size.width + rightEdgeRect.size.width), rect.size.height - (topEdgeRect.size.height + bottomEdgeRect.size.height));
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSaveGState(ctx);
	CGContextScaleCTM(ctx, 1, -1);
	CGContextTranslateCTM(ctx, 0, -rect.size.height);
    CGContextDrawImage(ctx, topLeftRect, _topLeftCorner);
    CGContextDrawImage(ctx, topRightRect, _topRightCorner);
    CGContextDrawImage(ctx, bottomRightRect, _bottomRightCorner);
    CGContextDrawImage(ctx, bottomLeftRect, _bottomLeftCorner);
    CGContextSaveGState(ctx);
    CGContextClipToRect(ctx, topEdgeRect);
    CGContextDrawTiledImage(ctx, topEdgeRect, _topEdgeFill);
    CGContextRestoreGState(ctx);
    CGContextSaveGState(ctx);
    CGContextClipToRect(ctx, leftEdgeRect);
    CGContextDrawTiledImage(ctx, leftEdgeRect, _leftEdgeFill);
    CGContextRestoreGState(ctx);
    CGContextSaveGState(ctx);
    CGContextClipToRect(ctx, bottomEdgeRect);
    CGContextDrawTiledImage(ctx, bottomEdgeRect, _bottomEdgeFill);
    CGContextRestoreGState(ctx);
    CGContextSaveGState(ctx);
    CGContextClipToRect(ctx, rightEdgeRect);
    CGContextDrawTiledImage(ctx, rightEdgeRect, _rightEdgeFill);
    CGContextRestoreGState(ctx);
    CGContextSaveGState(ctx);
    CGContextClipToRect(ctx, centerFillRect);
    CGContextDrawTiledImage(ctx, centerFillRect, _centerFill);
    CGContextRestoreGState(ctx);
    CGContextRestoreGState(ctx);
}

@end
