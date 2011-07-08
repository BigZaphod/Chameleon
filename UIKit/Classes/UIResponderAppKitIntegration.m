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

#import "UIResponderAppKitIntegration.h"
#import "UIEvent+UIPrivate.h"
#import "UIKey.h"
#import "UIApplication.h"
#import <AppKit/NSGraphics.h>

@implementation UIResponder (AppKitIntegration)

- (void)scrollWheelMoved:(CGPoint)delta withEvent:(UIEvent *)event
{
    [[self nextResponder] scrollWheelMoved:delta withEvent:event];
}

- (void)rightClick:(UITouch *)touch withEvent:(UIEvent *)event
{
    [[self nextResponder] rightClick:touch withEvent:event];
}

- (void)mouseExitedView:(UIView *)exited enteredView:(UIView *)entered withEvent:(UIEvent *)event
{
    [[self nextResponder] mouseExitedView:exited enteredView:entered withEvent:event];
}

- (void)mouseMoved:(CGPoint)delta withEvent:(UIEvent *)event
{
    [[self nextResponder] mouseMoved:delta withEvent:event];
}

- (id)mouseCursorForEvent:(UIEvent *)event
{
    return [[self nextResponder] mouseCursorForEvent:event];
}

- (BOOL)keyPressed:(UIKey *)key withEvent:(UIEvent *)event
{
    SEL command = nil;
    switch (key.type) {
        case UIKeyTypeReturn:
        case UIKeyTypeEnter: {
            command = @selector(insertNewline:);
            break;
        }
        case UIKeyTypeUpArrow: {
            command = @selector(moveUp:);
            break;
        }
        case UIKeyTypeDownArrow: {
            command = @selector(moveDown:);
            break;
        }
        case UIKeyTypeLeftArrow: {
            command = @selector(moveLeft:);
            break;
        }
        case UIKeyTypeRightArrow: {
            command = @selector(moveRight:);
            break;
        }
        case UIKeyTypePageUp: {
            command = @selector(pageUp:);
            break;
        }
        case UIKeyTypePageDown: {
            command = @selector(pageDown:);
            break;
        }
        case UIKeyTypeHome: {
            command = @selector(scrollToBeginningOfDocument:);
            break;
        }
        case UIKeyTypeEnd: {
            command = @selector(scrollToEndOfDocument:);
            break;
        }
        case UIKeyTypeInsert: {
            // TODO something
            break;
        }
        case UIKeyTypeDelete: {
            command = @selector(deleteForward:);
            break;
        }
        case UIKeyTypeEscape: {
            command = @selector(cancelOperation:);
            break;
        }
        case UIKeyTypeCharacter: {
            if (key.keyCode == 48) {
                if ([key isShiftKeyPressed]) {
                    command = @selector(insertBacktab:);
                } else {
                    command = @selector(insertTab:);
                }
            }
            break;
        }
    }

    if (command && [self tryToPerform:command with:self]) {
        return YES;
    } else {
        return [[self nextResponder] keyPressed:key withEvent:event];
    }
}

- (void) doCommandBySelector:(SEL)selector
{
    UIResponder* responder = self;
    do {
        if ([responder respondsToSelector:selector]) {
            [responder performSelector:selector withObject:nil];
            return;
        }
        responder = responder.nextResponder;
    } while (responder);
    NSBeep();
}

- (BOOL) tryToPerform:(SEL)selector with:(id)object
{
    if ([self respondsToSelector:selector]) {
        [self performSelector:selector withObject:nil];
        return YES;
    } else {
        return NO;
    }
}

@end
