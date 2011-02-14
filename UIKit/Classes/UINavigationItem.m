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

#import "UINavigationItem.h"
#import "UIBarButtonItem.h"

@implementation UINavigationItem
@synthesize title=_title, rightBarButtonItem=_rightBarButtonItem, titleView=_titleView, hidesBackButton=_hidesBackButton;
@synthesize leftBarButtonItem=_leftBarButtonItem, backBarButtonItem=_backBarButtonItem, prompt=_prompt;

- (id)initWithTitle:(NSString *)theTitle
{
	if ((self=[super init])) {
		self.title = theTitle;
	}
	return self;
}

- (void)dealloc
{
	[_backBarButtonItem release];
	[_leftBarButtonItem release];
	[_rightBarButtonItem release];
	[_title release];
	[_titleView release];
	[_prompt release];
	[super dealloc];
}

- (void)setLeftBarButtonItem:(UIBarButtonItem *)item animated:(BOOL)animated
{
	if (item != _leftBarButtonItem) {
		[_leftBarButtonItem release];
		_leftBarButtonItem = [item retain];
	}
}

- (void)setLeftBarButtonItem:(UIBarButtonItem *)item
{
	[self setLeftBarButtonItem:item animated:NO];
}

- (void)setRightBarButtonItem:(UIBarButtonItem *)item animated:(BOOL)animated
{
	if (item != _rightBarButtonItem) {
		[_rightBarButtonItem release];
		_rightBarButtonItem = [item retain];
	}
}

- (void)setRightBarButtonItem:(UIBarButtonItem *)item
{
	[self setRightBarButtonItem:item animated:NO];
}

- (void)setHidesBackButton:(BOOL)hidesBackButton animated:(BOOL)animated
{
	_hidesBackButton = hidesBackButton;
}

- (void)setHidesBackButton:(BOOL)hidesBackButton
{
	[self setHidesBackButton:hidesBackButton animated:NO];
}

- (UIBarButtonItem *)backBarButtonItem
{
	if (_backBarButtonItem) {
		return _backBarButtonItem;
	} else {
		return [[[UIBarButtonItem alloc] initWithTitle:(self.title ?: @"Back") style:UIBarButtonItemStylePlain target:nil action:nil] autorelease];
	}
}

@end
