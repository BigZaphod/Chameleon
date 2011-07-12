//
//  UISearchBar.m
//  UIKit
//
//  Created by Peter Steinberger on 23.03.11.
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

#import "UISearchBar.h"
#import "UISearchField.h"
#import "UIGraphics.h"
#import "UIColor.h"
#import "UIFont.h"
#import "UIImage+UIPrivate.h"
#import "UIImageView.h"

@interface UISearchBar () <UITextFieldDelegate>
- (void)sendTextDidChange;
@end

@interface NSObject (UISearchBarDelegate)
- (BOOL)searchBar:(UISearchBar *)searchBar doCommandBySelector:(SEL)selector;
@end

@implementation UISearchBar {
    UISearchField *_searchField;
	
	struct {
        BOOL shouldBeginEditing : 1;
        BOOL didBeginEditing : 1;
        BOOL shouldEndEditing : 1;
        BOOL didEndEditing : 1;
        BOOL textDidChange : 1;
        BOOL shouldChangeText : 1;
		BOOL searchButtonClicked : 1;
		BOOL bookmarkButtonClicked : 1;
		BOOL resultsButtonClicked : 1;
		BOOL selectedScopeButtonChanged : 1;
		BOOL doCommandBySelector : 1;
    } _delegateHas;
}
@synthesize delegate = _delegate;
@synthesize showsCancelButton = _showsCancelButton;
@synthesize placeholder = _placeholder;

- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame])) {
        _searchField = [[UISearchField alloc] initWithFrame:frame];
		_searchField.delegate = self;
		_searchField.borderStyle = UITextBorderStyleRoundedRect;
		_searchField.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
		_searchField.font = [UIFont fontWithName:@"Helvetica" size:11.0f];
		_searchField.leftView = [[[UIImageView alloc] initWithImage:[UIImage _searchBarIcon]] autorelease];
		_searchField.leftViewMode = UITextFieldViewModeAlways;
        [self addSubview:_searchField];
    }
    return self;
}

- (void)dealloc
{
    _delegate = nil;
    [_placeholder release];
    [_searchField release];
    [super dealloc];
}

- (void)drawRect:(CGRect)rect {
	[super drawRect:rect];
	
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	const CGFloat locations[] = { 0.0f, 1.0f };
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	
	NSArray *colors = [NSArray arrayWithObjects:(id) [UIColor colorWithRed:233.0f/255.0f green:236.0f/255.0f blue:239.0f/255.0f alpha:1.0f].CGColor, (id) [UIColor colorWithRed:215.0f/255.0f green:223.0f/255.0f blue:225.0f/255.0f alpha:1.0f].CGColor, nil];
	CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (CFArrayRef) colors, locations);
	
	CGContextDrawLinearGradient(context, gradient, CGPointMake(0.0f, 0.0f), CGPointMake(0.0f, self.bounds.size.height), kCGGradientDrawsBeforeStartLocation);
	
	[[UIColor colorWithRed:178.0f/255.0f green:188.0f/255.0f blue:195.0f/255.0f alpha:1.0f] set];
	CGContextFillRect(context, CGRectMake(0.0f, CGRectGetMaxY(self.bounds) - 1.0f, self.bounds.size.width, 1.0f));
	
	CFRelease(gradient);
	CFRelease(colorSpace);
}

- (NSString *)text
{
    return _searchField.text;
}

- (void)setText:(NSString *)text
{
    _searchField.text = text;
}

- (NSString *)placeholder {
	return _searchField.placeholder;
}

- (void)setPlaceholder:(NSString *)placeholder {
	_searchField.placeholder = placeholder;
}

- (void)setDelegate:(id <UISearchBarDelegate>)newDelegate {
	_delegate = newDelegate;
	
	_delegateHas.shouldBeginEditing = [self.delegate respondsToSelector:@selector(searchBarShouldBeginEditing:)];
	_delegateHas.didBeginEditing = [self.delegate respondsToSelector:@selector(searchBarTextDidBeginEditing:)];
	_delegateHas.shouldEndEditing = [self.delegate respondsToSelector:@selector(searchBarShouldEndEditing:)];
	_delegateHas.didEndEditing = [self.delegate respondsToSelector:@selector(searchBarTextDidEndEditing:)];
	_delegateHas.textDidChange = [self.delegate respondsToSelector:@selector(searchBar:textDidChange:)];
	_delegateHas.shouldChangeText = [self.delegate respondsToSelector:@selector(searchBar:shouldChangeTextInRange:replacementText:)];
	_delegateHas.searchButtonClicked = [self.delegate respondsToSelector:@selector(searchBarSearchButtonClicked:)];
	_delegateHas.bookmarkButtonClicked = [self.delegate respondsToSelector:@selector(searchBarBookmarkButtonClicked:)];
	_delegateHas.resultsButtonClicked = [self.delegate respondsToSelector:@selector(searchBarResultsListButtonClicked:)];;
	_delegateHas.selectedScopeButtonChanged = [self.delegate respondsToSelector:@selector(searchBar:selectedScopeButtonIndexDidChange:)];
	_delegateHas.doCommandBySelector = [self.delegate respondsToSelector:@selector(searchBar:doCommandBySelector:)];
}

- (BOOL)becomeFirstResponder {
	return [_searchField becomeFirstResponder];
}

- (BOOL)resignFirstResponder {
	return [_searchField resignFirstResponder];
}

#pragma mark UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
	BOOL shouldChange = YES;
	if(_delegateHas.shouldChangeText) shouldChange = [self.delegate searchBar:self shouldChangeTextInRange:range replacementText:string];
	
	if(shouldChange && _delegateHas.textDidChange) {
		[self performSelector:@selector(sendTextDidChange) withObject:nil afterDelay:0];
	}
	
	return shouldChange;
}

- (BOOL)textField:(UITextField *)textField doCommandBySelector:(SEL)selector {
	if(_delegateHas.doCommandBySelector) {
		return [(id)self.delegate searchBar:self doCommandBySelector:selector];
	}
	
	return NO;
}

- (void)sendTextDidChange {
	[self.delegate searchBar:self textDidChange:_searchField.text];
}

@end
