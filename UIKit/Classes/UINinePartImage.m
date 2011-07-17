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
    CGFloat _tch;
    CGFloat _lcw;
    CGFloat _bch;
    CGFloat _rcw;

    CGImageRef _topLeftCorner;
    CGImageRef _topEdgeFill;
    CGImageRef _topRightCorner;
    CGImageRef _leftEdgeFill;
    CGColorRef _centerFill;
    CGImageRef _rightEdgeFill;
    CGImageRef _bottomLeftCorner;
    CGImageRef _bottomEdgeFill;
    CGImageRef _bottomRightCorner;
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
        CGColorRelease(_centerFill);
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

- (id)initWithCGImage:(CGImageRef)image leftCapWidth:(NSInteger)leftCapWidth topCapHeight:(NSInteger)topCapHeight
{
    assert(image);
    assert(leftCapWidth > 0);
    assert(topCapHeight > 0);
    if (nil != (self = [super initWithCGImage:image])) {
        CGFloat w = CGImageGetWidth(image);
        CGFloat h = CGImageGetHeight(image);
        
        _tch = MIN(topCapHeight, h);
        _lcw = MIN(leftCapWidth, w);
        
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
            uint8_t pixel[4] = { 0 };
            CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
            CGContextRef context = CGBitmapContextCreate(pixel, 1, 1, 8, 4, colorspace, kCGImageAlphaPremultipliedLast);
            CFRelease(colorspace);
            CGContextDrawImage(context, CGRectMake(-_rcw, -_bch, w, h), image);
            CGContextRelease(context);
            CGFloat a = pixel[3] / 255.0;
            CGFloat r = pixel[0] / 255.0 / a;
            CGFloat g = pixel[1] / 255.0 / a;
            CGFloat b = pixel[2] / 255.0 / a;
            _centerFill = CGColorCreateGenericRGB(r, g, b, a);
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

- (NSInteger) leftCapWidth
{
    return _lcw;
}

- (NSInteger) topCapHeight
{
    return _tch;
}

- (void) drawInRect:(CGRect)rect
{
    CGContextRef c = UIGraphicsGetCurrentContext();
    CGContextSaveGState(c);
    CGContextTranslateCTM(c, rect.origin.x, rect.origin.y + rect.size.height);
    CGContextScaleCTM(c, 1.0, -1.0);

    CGFloat const cw = rect.size.width - (_lcw + _rcw);
    CGFloat const ch = rect.size.height - (_tch + _bch);
    
    CGFloat const ty = rect.origin.y + rect.size.height - _tch;
    CGFloat const cy = rect.origin.y + _bch;
    CGFloat const by = rect.origin.y;

    CGFloat const lx = rect.origin.x;
    CGFloat const cx = rect.origin.x + _lcw;
    CGFloat const rx = rect.origin.x + rect.size.width - _rcw;
    
    if (_topLeftCorner) {
        CGContextDrawImage(c, CGRectMake(lx, ty, _lcw, _tch), _topLeftCorner);
    }
    if (_topEdgeFill) {
        CGContextDrawImage(c, CGRectMake(cx, ty, cw, _tch), _topEdgeFill);
    }
    if (_topRightCorner) {
        CGContextDrawImage(c, CGRectMake(rx, ty, _rcw, _tch), _topRightCorner);
    }

    if (_leftEdgeFill) {
        CGContextDrawImage(c, CGRectMake(lx, cy, _lcw, ch), _leftEdgeFill);
    }
    if (_centerFill) {
        CGContextSetFillColorWithColor(c, _centerFill);
        CGContextFillRect(c, CGRectMake(cx, cy, cw, ch));
    }
    if (_rightEdgeFill) {
        CGContextDrawImage(c, CGRectMake(rx, cy, _rcw, ch), _rightEdgeFill);
    }
    
    if (_bottomLeftCorner) {
        CGContextDrawImage(c, CGRectMake(lx, by, _lcw, _bch), _bottomLeftCorner);
    }
    if (_bottomEdgeFill) {
        CGContextDrawImage(c, CGRectMake(cx, by, cw, _bch), _bottomEdgeFill);
    }
    if (_bottomRightCorner) {
        CGContextDrawImage(c, CGRectMake(rx, by, _rcw, _bch), _bottomRightCorner);
    }
    
    CGContextRestoreGState(c);
}

@end
