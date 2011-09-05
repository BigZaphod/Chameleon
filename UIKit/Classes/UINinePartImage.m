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

@implementation UINinePartImage {
    UIEdgeInsets _capInsets;
    
    CGImageRef _topLeftCorner;
    CGImageRef _topEdgeFill;
    CGImageRef _topRightCorner;
    CGImageRef _leftEdgeFill;
    CGImageRef _centerFill;
    CGImageRef _rightEdgeFill;
    CGImageRef _bottomLeftCorner;
    CGImageRef _bottomEdgeFill;
    CGImageRef _bottomRightCorner;
}

- (id)initWithCGImage:(CGImageRef)image edge:(UIEdgeInsets)edge
{   
    if (nil != (self = [super initWithCGImage:image])) {
        _capInsets = edge;
        CGFloat w = CGImageGetWidth(image);
        CGFloat h = CGImageGetHeight(image);
        CGRect fullRect = CGRectMake(0, 0, w, h);
        CGRect middleRect = UIEdgeInsetsInsetRect(fullRect,edge);
        
        
        
        //TOP 
        if (edge.top>0)
        {
            if (edge.left >0)
                _topLeftCorner = CGImageCreateWithImageInRect(image, CGRectMake(0.0, 0.0, edge.left, edge.top));
            
            _topEdgeFill = CGImageCreateWithImageInRect(image, CGRectMake(edge.left, 0.0, CGRectGetWidth(middleRect), edge.top));
            
            if (edge.right >0)
                _topRightCorner =  CGImageCreateWithImageInRect(image, CGRectMake(w-edge.right, 0.0, edge.right, edge.top));
        }
        
        //MIDDLE
        {
            CGFloat y = edge.top;
            if (edge.left >0)
                _leftEdgeFill = CGImageCreateWithImageInRect(image, CGRectMake(0.0, y, edge.left, CGRectGetHeight(middleRect)));
            
            _centerFill = CGImageCreateWithImageInRect(image, middleRect);
            
            if (edge.right >0)
                _rightEdgeFill =  CGImageCreateWithImageInRect(image, CGRectMake(w-edge.right, y, edge.right, CGRectGetHeight(middleRect)));
        
        }
        
        //BOTTOM
        if (edge.bottom>0)
        {
            CGFloat y = h-edge.bottom;
            if (edge.left >0)
                _bottomLeftCorner = CGImageCreateWithImageInRect(image, CGRectMake(0.0, y, edge.left, edge.bottom));
            
            _bottomEdgeFill = CGImageCreateWithImageInRect(image, CGRectMake(edge.left, y, CGRectGetWidth(middleRect), edge.bottom));
            
            if (edge.right >0)
                _bottomRightCorner =  CGImageCreateWithImageInRect(image, CGRectMake(w-edge.right, y, edge.right, edge.bottom));
        }
        
        
        
    }
    return self;
    

}



//LEGACY
- (id)initWithCGImage:(CGImageRef)image leftCapWidth:(NSInteger)leftCapWidth topCapHeight:(NSInteger)topCapHeight
{
    NSParameterAssert(image);
    NSAssert(leftCapWidth > 0, @"leftCapWidth less than 0");
    NSAssert(topCapHeight > 0, @"topCapHeight less than 0");
        

    if (nil != (self = [super initWithCGImage:image])) {
        CGFloat w = CGImageGetWidth(image);
        CGFloat h = CGImageGetHeight(image);
        
        CGFloat _lcw = MIN(leftCapWidth, w);
        CGFloat _tch = MIN(topCapHeight, h);
        CGFloat _rcw , _bch;
        
        NSInteger x;
        if (w > leftCapWidth + 1.0) {
            x = 2;
            _rcw = w - 1.0 - leftCapWidth;
        } else if (w == leftCapWidth + 1.0) {
            x = 1;
        } else {
            x = 0;
        }
        
        NSInteger y;
        if (h >= topCapHeight + 1.0) {
            y = 2;
            _bch = h - 1.0 - topCapHeight;
        } else if (h == topCapHeight + 1.0) {
            y = 1;
        } else {
            y = 0;
        }
        
        _capInsets = UIEdgeInsetsMake(_tch, _lcw, _bch, _rcw);
        
        static NSUInteger const TABLE[3][3] = {
            { 0001, 0011, 0111 },
            { 0003, 0033, 0333 },
            { 0007, 0077, 0777 },
        };
        NSUInteger const bits = TABLE[x][y];

        if (bits & 0001) {
            _topLeftCorner = CGImageCreateWithImageInRect(image, CGRectMake(0.0, 0.0, _lcw, _tch));
        }
        if (bits & 0010) {
            _topEdgeFill = CGImageCreateWithImageInRect(image, CGRectMake(_lcw, 0.0, 1.0, _tch));
        }
        if (bits & 0100) {
            _topRightCorner = CGImageCreateWithImageInRect(image, CGRectMake(_lcw + 1.0, 0.0, _rcw, _tch));
        }
        
        if (bits & 0002) {
            _leftEdgeFill = CGImageCreateWithImageInRect(image, CGRectMake(0, _tch, _lcw, 1.0));
        }
        if (bits & 0020) {
            _centerFill = CGImageCreateWithImageInRect(image, CGRectMake(_tch, _lcw, 1.0, 1.0));
        }
        if (bits & 0200) {
            _rightEdgeFill = CGImageCreateWithImageInRect(image, CGRectMake(w - _rcw, _tch, _rcw, 1.0));
        }
        
        if (bits & 0004) {
            _bottomLeftCorner = CGImageCreateWithImageInRect(image, CGRectMake(0.0, h - _bch, _lcw, _bch));
        }
        if (bits & 0040) {
            _bottomEdgeFill = CGImageCreateWithImageInRect(image, CGRectMake(_lcw, h - _bch, 1.0, _bch));
        }
        if (bits & 0400) {
            _bottomRightCorner = CGImageCreateWithImageInRect(image, CGRectMake(_lcw + 1.0, h - _bch, _rcw, _bch));
        }
    }
    return self;
}

- (void) dealloc
{
    if (_topLeftCorner) {
        CGImageRelease(_topLeftCorner);
    }
    if (_topEdgeFill) {
        CGImageRelease(_topEdgeFill);
    }
    if (_topRightCorner) {
        CGImageRelease(_topRightCorner);
    }
    if (_leftEdgeFill) {
        CGImageRelease(_leftEdgeFill);
    }
    if (_centerFill) {
        CGImageRelease(_centerFill);
    }
    if (_rightEdgeFill) {
        CGImageRelease(_rightEdgeFill);
    }
    if (_bottomLeftCorner) {
        CGImageRelease(_bottomLeftCorner);
    }
    if (_bottomEdgeFill) {
        CGImageRelease(_bottomEdgeFill);
    }
    if (_bottomRightCorner) {
        CGImageRelease(_bottomRightCorner);
    }
    [super dealloc];
}




- (NSInteger) leftCapWidth
{
    return _capInsets.left;
}

- (NSInteger) topCapHeight
{
    return _capInsets.top;
}

- (UIEdgeInsets)capInsets 
{
    return _capInsets;
}

- (void) drawInRect:(CGRect)rect
{
    CGContextRef c = UIGraphicsGetCurrentContext();
    CGContextSaveGState(c);
    CGContextTranslateCTM(c, rect.origin.x, rect.origin.y + rect.size.height);
    CGContextScaleCTM(c, 1.0, -1.0);
    
    CGFloat const cw = rect.size.width - (_capInsets.left + _capInsets.right);
    CGFloat const ch = rect.size.height - (_capInsets.top + _capInsets.bottom);
    
    CGFloat const ty = rect.origin.y + (rect.size.height - _capInsets.top);
    CGFloat const cy = rect.origin.y + _capInsets.bottom;
    CGFloat const by = rect.origin.y;

    CGFloat const lx = rect.origin.x;
    CGFloat const cx = rect.origin.x + _capInsets.left;
    CGFloat const rx = rect.origin.x + (rect.size.width - _capInsets.right);
    
    if (_topLeftCorner) {
        CGContextDrawImage(c, CGRectMake(lx, ty, _capInsets.left, _capInsets.top), _topLeftCorner);
    }
    if (_topEdgeFill) {
        if (cw > 1 && _topRightCorner)
            CGContextDrawTiledImage (c, CGRectMake(cx, ty, cw, _capInsets.top), _topEdgeFill);
        else
            CGContextDrawImage(c, CGRectMake(cx, ty, cw, _capInsets.top), _topEdgeFill);
    }
    if (_topRightCorner) {
        CGContextDrawImage(c, CGRectMake(rx, ty, _capInsets.right, _capInsets.top), _topRightCorner);
    }

    if (_leftEdgeFill) {
        if (ch > 1 && _bottomLeftCorner)
            CGContextDrawTiledImage(c, CGRectMake(lx, cy, _capInsets.left, ch), _leftEdgeFill);
        else
            CGContextDrawImage(c, CGRectMake(lx, cy, _capInsets.left, ch), _leftEdgeFill);
    }
    if (_centerFill) {
        if (cw > 1 || ch > 1)
            CGContextDrawTiledImage(c, CGRectMake(cx, cy, cw, ch), _centerFill);
        else
            CGContextDrawImage(c, CGRectMake(cx, cy, cw, ch), _centerFill);
    }
    if (_rightEdgeFill) {
        if (ch > 1 && _bottomRightCorner)
            CGContextDrawTiledImage(c, CGRectMake(rx, cy, _capInsets.right, ch), _rightEdgeFill);
        else
            CGContextDrawImage(c, CGRectMake(rx, cy, _capInsets.right, ch), _rightEdgeFill);
    }
    
    if (_bottomLeftCorner) {
        CGContextDrawImage(c, CGRectMake(lx, by, _capInsets.left, _capInsets.bottom), _bottomLeftCorner);
    }
    if (_bottomEdgeFill) {
        if (cw > 1 && _bottomRightCorner)
            CGContextDrawTiledImage(c, CGRectMake(cx, by, cw, _capInsets.bottom), _bottomEdgeFill);
        else
            CGContextDrawImage(c, CGRectMake(cx, by, cw, _capInsets.bottom), _bottomEdgeFill);
    }
    if (_bottomRightCorner) {
        CGContextDrawImage(c, CGRectMake(rx, by, _capInsets.right, _capInsets.bottom), _bottomRightCorner);
    }
    
    CGContextRestoreGState(c);
}

@end
