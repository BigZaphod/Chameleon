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

#import "UITableViewSectionLabel.h"
#import "UIGraphics.h"
#import "AppKitIntegration.h"
#import <AppKit/NSGradient.h>

@implementation UITableViewSectionLabel
+ (UITableViewSectionLabel *)sectionLabelWithTitle:(NSString *)title
{
    UITableViewSectionLabel *label = [[self alloc] init];
    label.text = [NSString stringWithFormat:@"  %@", title];
    label.font = [UIFont boldSystemFontOfSize:17];
    label.textColor = [UIColor whiteColor];
    label.shadowColor = [UIColor colorWithRed:100/255.f green:105/255.f blue:110/255.f alpha:1];
    label.shadowOffset = CGSizeMake(0,1);
    return [label autorelease];
}

- (void)drawRect:(CGRect)rect
{
    const CGSize size = self.bounds.size;
    
    [[UIColor colorWithRed:166/255.f green:177/255.f blue:187/255.f alpha:1] setFill];
    UIRectFill(CGRectMake(0,0,size.width,1));
    
    UIColor *startColor = [UIColor colorWithRed:145/255.f green:158/255.f blue:171/255.f alpha:1];
    UIColor *endColor = [UIColor colorWithRed:185/255.f green:193/255.f blue:201/255.f alpha:1];
    
    NSGradient *gradient = [[NSGradient alloc] initWithStartingColor:[startColor NSColor] endingColor:[endColor NSColor]];
    [gradient drawFromPoint:NSMakePoint(0,1) toPoint:NSMakePoint(0,size.height-1) options:0];
    [gradient release];
    
    [[UIColor colorWithRed:153/255.f green:158/255.f blue:165/255.f alpha:1] setFill];
    UIRectFill(CGRectMake(0,size.height-1,size.width,1));
    
    [super drawRect:rect];
}

@end
