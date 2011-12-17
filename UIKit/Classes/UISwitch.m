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

#import "UISwitch.h"
#import "UIColor.h"
#import "UIGraphics.h"
#import "UITouch.h"
#import "UIImage+UIPrivate.h"

@implementation UISwitch
@synthesize on = _on;
@synthesize onImage = _onImage;
@synthesize offImage = _offImage;

#pragma mark UIView

- (id)initWithFrame:(CGRect)frame
{
    if ((self=[super initWithFrame:frame])) {
        // UIView's initWithFrame: calls setFrame:, so we'll enforce UISwitch's size invariant down there (see below)
        
        self.backgroundColor = [UIColor clearColor];
        
        self.onImage  = [UIImage _switchOnImage];
        self.offImage = [UIImage _switchOffImage];
        self.on = NO;
    }
    return self;
}

- (void) dealloc
{
    [_onImage release];
    [_offImage release];
}

- (void)drawRect:(CGRect)frame
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    
    
    CGRect rect = frame;
    if (self.on)
        [self.onImage drawInRect:rect];
    else
        [self.offImage drawInRect:rect];

    
    CGContextRestoreGState(context);
}


#pragma mark UIResponder

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGFloat x = [touch locationInView:self].x;
    CGFloat y = [touch locationInView:self].y;
    
    // Ignore touches that don't matter
    if (x < 0 || x > self.frame.size.width
        || y < 0 || y > self.frame.size.height) {
        return;
    }
    
    self.on = !self.on;
    [self setNeedsDisplay];
    [self sendActionsForControlEvents:UIControlEventValueChanged];
}

#pragma mark UISwitch

- (void)setOn:(BOOL)on animated:(BOOL)animated
{
    _on = on;
    [self setNeedsDisplay];
}

- (void)setOn:(BOOL)on
{
    [self setOn:on animated:NO];
}

- (void)setFrame:(CGRect)frame
{
    frame.size = CGSizeMake(94, 27);
    [super setFrame:frame];
}

@end
