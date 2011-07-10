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

#import "UITableViewCell+UIPrivate.h"
#import "UITableViewCellSeparator.h"
#import "UIColor.h"
#import "UILabel.h"
#import "UIImageView.h"
#import "UIFont.h"
#import "UIGraphics.h"
#import "UITableView.h"
#import "UITableViewCellBackgroundView.h"
#import "UITableViewCellSelectedBackgroundView.h"
#import "UITableViewCellLayoutManager.h"


extern CGFloat _UITableViewDefaultRowHeight;


@interface UITableViewCell (UITableViewCellInternal)
- (UITableViewCellLayoutManager*) layoutManager;
- (void) _setSeparatorStyle:(UITableViewCellSeparatorStyle)theStyle color:(UIColor*)theColor;
- (void) _setTableViewStyle:(NSUInteger)tableViewStyle;
- (void) _setHighlighted:(BOOL)highlighted forViews:(id)subviews;
- (void) showSelectedBackgroundView:(BOOL)selected animated:(BOOL)animated;
- (void) _setupDefaultSelectedBackgroundView;
- (void) _setupDefaultAccessoryView;
@end


@implementation UITableViewCell {
@private
    UITableViewCellStyle _style;
    UITableViewCellSeparator *_separatorView;
    UIView *_contentView;
    UILabel *_textLabel;
    UILabel *_detailTextLabel; // not yet displayed!
    UIImageView *_imageView;
    UIView *_backgroundView;
    UIView *_selectedBackgroundView;
    UITableViewCellAccessoryType _accessoryType;
    UIView *_accessoryView;
    UITableViewCellAccessoryType _editingAccessoryType;
    UITableViewCellSelectionStyle _selectionStyle;
	UITableViewCellSectionLocation _sectionLocation;
    NSInteger _indentationLevel;
    BOOL _editing;
    BOOL _selected;
    BOOL _highlighted;
    BOOL _showingDeleteConfirmation;
    NSString *_reuseIdentifier;
    CGFloat _indentationWidth;
    struct {
        BOOL tableViewStyleIsGrouped : 1;
        BOOL usingDefaultSelectedBackgroundView : 1;
        BOOL usingDefaultAccessoryView : 1;
    } _tableCellFlags;
}
@synthesize accessoryType=_accessoryType; 
@synthesize accessoryView=_accessoryView;
@synthesize backgroundView=_backgroundView;
@synthesize contentView=_contentView;
@synthesize detailTextLabel = _detailTextLabel;
@synthesize editing = _editing;
@synthesize editingAccessoryType=_editingAccessoryType;
@synthesize highlighted=_highlighted;
@synthesize imageView=_imageView;
@synthesize indentationLevel=_indentationLevel;
@synthesize indentationWidth=_indentationWidth;
@synthesize reuseIdentifier=_reuseIdentifier;
@synthesize sectionLocation=_sectionLocation;
@synthesize selected=_selected;
@synthesize selectedBackgroundView=_selectedBackgroundView;
@synthesize selectionStyle=_selectionStyle;
@synthesize showingDeleteConfirmation = _showingDeleteConfirmation;
@synthesize textLabel=_textLabel;

static UIImage* accessoryCheckmarkImage;
static UIImage* accessoryCheckmarkImageHighlighted;
static UIImage* accessoryDisclosureIndicatorImage;
static UIImage* accessoryDisclosureIndicatorImageHighlighted;

+ (void) initialize
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSBundle* bundle = [NSBundle bundleForClass:[self class]];
        accessoryCheckmarkImage = [[UIImage imageWithContentsOfFile:[bundle pathForImageResource:@"<UITableViewCell> accessoryCheckmark"]] retain];
        accessoryCheckmarkImageHighlighted = [[UIImage imageWithContentsOfFile:[bundle pathForImageResource:@"<UITableViewCell> accessoryCheckmarkHighlighted"]] retain];
        accessoryDisclosureIndicatorImage = [[UIImage imageWithContentsOfFile:[bundle pathForImageResource:@"<UITableViewCell> accessoryDisclosureIndicatorImage"]] retain];
        accessoryDisclosureIndicatorImageHighlighted = [[UIImage imageWithContentsOfFile:[bundle pathForImageResource:@"<UITableViewCell> accessoryDisclosureIndicatorHighlighted"]] retain];
    });
}

- (void) dealloc
{
	[_separatorView release];
	[_contentView release];
    [_accessoryView release];
	[_textLabel release];
    [_detailTextLabel release];
	[_imageView release];
	[_backgroundView release];
	[_selectedBackgroundView release];
	[_reuseIdentifier release];
	
	[super dealloc];
}

- (id) initWithFrame:(CGRect)frame
{
	if (nil != (self = [super initWithFrame:frame])) {
        _indentationWidth = 10;
		_style = UITableViewCellStyleDefault;
		_accessoryType = UITableViewCellAccessoryNone;
		_editingAccessoryType = UITableViewCellAccessoryNone;
		_selectionStyle = UITableViewCellSelectionStyleBlue;
		
		super.backgroundColor = [UIColor whiteColor];
	}
	return self;
}

- (id) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString*)reuseIdentifier
{
	if (nil != (self = [self initWithFrame:CGRectMake(0,0,320,_UITableViewDefaultRowHeight)])) {
		_style = style;
		_reuseIdentifier = [reuseIdentifier copy];
	}
	return self;
}


#pragma mark Reusing Cells

- (void) prepareForReuse
{
}


#pragma mark Managing Text as Cell Content

- (UILabel*) textLabel
{
    if (!_textLabel) {
        _textLabel = [[UILabel alloc] init];
        _textLabel.backgroundColor = [UIColor clearColor];
        _textLabel.textColor = [UIColor blackColor];
        _textLabel.highlightedTextColor = [UIColor whiteColor];
        _textLabel.font = [UIFont boldSystemFontOfSize:17];
        [self.contentView addSubview:_textLabel];
    }
    return _textLabel;
}

- (UILabel*) detailTextLabel
{
    if (!_detailTextLabel && _style == UITableViewCellStyleSubtitle) {
        _detailTextLabel = [[UILabel alloc] init];
        _detailTextLabel.backgroundColor = [UIColor clearColor];
        _detailTextLabel.textColor = [UIColor grayColor];
        _detailTextLabel.highlightedTextColor = [UIColor whiteColor];
        _detailTextLabel.font = [UIFont boldSystemFontOfSize:14];
        [self.contentView addSubview:_detailTextLabel];
    }
    return _detailTextLabel;
}


#pragma mark Managing Images as Cell Content

- (UIImageView*) imageView
{
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
        _imageView.contentMode = UIViewContentModeCenter;
        [self.contentView addSubview:_imageView];
    }
    return _imageView;
}


#pragma mark Managing Accessory Views

- (void) setAccessoryType:(UITableViewCellAccessoryType)accessoryType
{
    if (_accessoryType != accessoryType) {
        [_accessoryView removeFromSuperview];
        [_accessoryView release], _accessoryView = nil;
        _accessoryType = accessoryType;
        [self _setupDefaultAccessoryView];
    }
}

- (UIView*) accessoryView
{
    if (_tableCellFlags.usingDefaultAccessoryView) {
        return nil;
    }
    return _accessoryView;
}

- (void) setAccessoryView:(UIView*)accessoryView 
{
	if (_accessoryView != accessoryView) {
        [_accessoryView removeFromSuperview];
        [_accessoryView release], _accessoryView = nil;
        if (accessoryView) {
            _tableCellFlags.usingDefaultAccessoryView = NO;
            _accessoryView = [accessoryView retain];
            [self.contentView addSubview:_accessoryView];
        } else {
            [self _setupDefaultAccessoryView];
        }
        [self setNeedsLayout];
	}
}


#pragma mark Accessing Views of the Cell Object

- (UIView*) contentView
{
    if (!_contentView) {
        _contentView = [[UIView alloc] init];
		_contentView.backgroundColor = [UIColor clearColor];
        [self addSubview:_contentView];
    }
    return _contentView;
}

- (UIView*) backgroundView
{
    if (!_backgroundView && _tableCellFlags.tableViewStyleIsGrouped) {
        _backgroundView = [[UITableViewCellBackgroundView alloc] init];
        [self insertSubview:_backgroundView atIndex:0];
    }
    return _backgroundView;
}

- (void) setBackgroundView:(UIView*)backgroundView
{
	if (backgroundView != _backgroundView) {
		[_backgroundView removeFromSuperview];
		[_backgroundView release];
        if (backgroundView) {
            _backgroundView = [backgroundView retain];
            [self insertSubview:_backgroundView atIndex:0];
        }
	}
}

- (UIView*) selectedBackgroundView
{
    if (!_selectedBackgroundView) {
        if (_tableCellFlags.tableViewStyleIsGrouped) {
            [self _setupDefaultSelectedBackgroundView];
        }
    } else if (_tableCellFlags.usingDefaultSelectedBackgroundView && !_tableCellFlags.tableViewStyleIsGrouped) {
        return nil;
    }
    return _selectedBackgroundView;
}

- (void) setSelectedBackgroundView:(UIView*)selectedBackgroundView
{
	if (selectedBackgroundView != _selectedBackgroundView) {
		[_selectedBackgroundView removeFromSuperview];
		[_selectedBackgroundView release];

        _tableCellFlags.usingDefaultSelectedBackgroundView = NO;
        if (selectedBackgroundView) {
            _selectedBackgroundView = [selectedBackgroundView retain];
            [self showSelectedBackgroundView:self.selected animated:NO];
        }
	}
}

#pragma mark Managing Cell Selection and Highlighting

- (void) setSelectionStyle:(UITableViewCellSelectionStyle)selectionStyle
{
    if (_selectionStyle != selectionStyle) {
        _selectionStyle = selectionStyle;
        if (_selectedBackgroundView && _tableCellFlags.usingDefaultSelectedBackgroundView) {
            [(UITableViewCellSelectedBackgroundView*)_selectedBackgroundView setSelectionStyle:selectionStyle];
        }
    }
}

- (void) setSelected:(BOOL)selected
{
	[self setSelected:selected animated:NO];
}

- (void) setSelected:(BOOL)selected animated:(BOOL)animated
{
	if (selected != _selected) {
		_selected = selected;
        [self showSelectedBackgroundView:selected animated:animated];
	}
}

- (void) setHighlighted:(BOOL)highlighted
{
	[self setHighlighted:highlighted animated:NO];
}

- (void) setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
	if (_highlighted != highlighted) {
		_highlighted = highlighted;
        [self showSelectedBackgroundView:highlighted animated:animated];
	}
}


#pragma mark Overridden

- (UIColor*) backgroundColor
{
    return self.backgroundView.backgroundColor;
}

- (void) setBackgroundColor:(UIColor*)backgroundColor
{
    self.backgroundView.backgroundColor = backgroundColor;
}

- (void) layoutSubviews
{
	[super layoutSubviews];
	CGRect bounds = self.bounds;
	
    // TODO: Push this code into a "layout manager" appropriate to the cell
    //       style.
    
	CGRect contentFrame = {
        .origin = { 
            .x = 0.0,
            .y = 0.0,
        },
        .size = {
            .width = bounds.size.width,
            .height = bounds.size.height - (_separatorView ? 1.0 : 0.0)
        }
    };
    
	if (_accessoryView) {
		CGSize accessorySize = [_accessoryView sizeThatFits:bounds.size];
        CGRect accessoryFrame = {
            .origin = { 
                .x = bounds.size.width - accessorySize.width - 10.0,
                .y = round(0.5 * (bounds.size.height - accessorySize.height)),
            },
            .size = accessorySize
        };
		_accessoryView.frame = accessoryFrame;
		contentFrame.size.width = accessoryFrame.origin.x - 1.0;
	}
		
	if (_backgroundView) {
        _backgroundView.frame = bounds;
	}
    if (_selectedBackgroundView) {
        _selectedBackgroundView.frame = bounds;
    }
    if (_contentView) {
        _contentView.frame = contentFrame;
	}
	if (_separatorView) {
		_separatorView.frame = CGRectMake(0.0, bounds.size.height - 1.0, bounds.size.width, 1.0);
	}
	
	if (_style == UITableViewCellStyleDefault) {
		const CGFloat padding = 5.0;
		
        if (_imageView) {
            _imageView.frame = CGRectMake(padding, 0.0, 30.0, contentFrame.size.height);
        }
		
		CGRect textRect;
		textRect.origin = CGPointMake(padding+_imageView.frame.size.width+padding,0);
		textRect.size = CGSizeMake(MAX(0,contentFrame.size.width-textRect.origin.x-padding),contentFrame.size.height);
		_textLabel.frame = textRect;
	} else if (_style == UITableViewCellStyleSubtitle) {
		const CGFloat padding = 5;
		
		BOOL showImage = (_imageView.image != nil);
		_imageView.frame = CGRectMake(padding,0,(showImage? 30:0),contentFrame.size.height);
		
		CGSize textSize = [_textLabel.text sizeWithFont:_textLabel.font];
		
		CGRect textRect;
		textRect.origin = CGPointMake(padding+_imageView.frame.size.width+padding,round(-0.5*textSize.height));
		textRect.size = CGSizeMake(MAX(0,contentFrame.size.width-textRect.origin.x-padding),contentFrame.size.height);
		_textLabel.frame = textRect;
		
		CGSize detailTextSize = [_detailTextLabel.text sizeWithFont:_detailTextLabel.font];
		
		CGRect detailTextRect;
		detailTextRect.origin = CGPointMake(padding+_imageView.frame.size.width+padding,round(0.5*detailTextSize.height));
		detailTextRect.size = CGSizeMake(MAX(0,contentFrame.size.width-textRect.origin.x-padding),contentFrame.size.height);
		_detailTextLabel.frame = detailTextRect;
	}
}


#pragma mark Internals

- (UITableViewCellLayoutManager*) layoutManager
{
    return [UITableViewCellLayoutManager layoutManagerForTableViewCellStyle:_style];
}

- (void) _setSeparatorStyle:(UITableViewCellSeparatorStyle)style color:(UIColor*)color
{
    switch (style) {
        case UITableViewCellSeparatorStyleNone: {
            if (_separatorView) {
                [_separatorView removeFromSuperview];
                [_separatorView release], _separatorView = nil;
                [self setNeedsLayout];
            }
            break;
        }
            
        case UITableViewCellSeparatorStyleSingleLine:
        case UITableViewCellSeparatorStyleSingleLineEtched: {
            if (!_separatorView) {
                _separatorView = [[UITableViewCellSeparator alloc] init];
                _separatorView.autoresizingMask = NSViewWidthSizable | NSViewMinXMargin;
                [self addSubview:_separatorView];
                [self setNeedsLayout];
            }
            _separatorView.color = color;
            _separatorView.style = style;
            break;
        }
    }
}

- (void) _setTableViewStyle:(NSUInteger)tableViewStyle
{
    if (_tableCellFlags.tableViewStyleIsGrouped != tableViewStyle) {
        _tableCellFlags.tableViewStyleIsGrouped = tableViewStyle;
        [self setNeedsLayout];
    }
}

- (void) _setHighlighted:(BOOL)highlighted forViews:(id)subviews
{
	for (id view in subviews) {
		if ([view respondsToSelector:@selector(setHighlighted:)]) {
			[view setHighlighted:highlighted];
		}
		[self _setHighlighted:highlighted forViews:[view subviews]];
	}
}

- (void) showSelectedBackgroundView:(BOOL)selected animated:(BOOL)animated
{
    if (_selectionStyle != UITableViewCellSelectionStyleNone) {
        [UIView animateWithDuration:!animated ? 0.0 : 0.2 delay:0.0 options:UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionTransitionNone | UIViewAnimationOptionAllowUserInteraction
            animations:^{
                [self _setHighlighted:selected forViews:[self.contentView subviews]];
                if (selected) {
                    if (!_selectedBackgroundView) {
                        [self _setupDefaultSelectedBackgroundView];
                    }
                    if (_backgroundView) {
                        [self insertSubview:_selectedBackgroundView aboveSubview:_backgroundView];
                    } else {
                        [self insertSubview:_selectedBackgroundView atIndex:0];
                    }
                    [self setNeedsLayout];
                } else {
                    [_selectedBackgroundView removeFromSuperview];
                }
            }
            completion:nil
        ];
    }
}

- (void) _setupDefaultSelectedBackgroundView
{
    assert(!_selectedBackgroundView);
    assert(!_tableCellFlags.usingDefaultSelectedBackgroundView);
    _tableCellFlags.usingDefaultSelectedBackgroundView = YES;
    UITableViewCellSelectedBackgroundView* selectedBackgroundView = [[UITableViewCellSelectedBackgroundView alloc] init];
    selectedBackgroundView.selectionStyle = self.selectionStyle;
    _selectedBackgroundView = selectedBackgroundView;
}

- (void) _setupDefaultAccessoryView
{
    assert(!_accessoryView);
    switch (_accessoryType) {
        case UITableViewCellAccessoryNone: {
            break;
        }
            
        case UITableViewCellAccessoryCheckmark: {
            UIImageView* checkmark = [[UIImageView alloc] initWithImage:accessoryCheckmarkImage];
            checkmark.highlightedImage = accessoryCheckmarkImageHighlighted;
            _accessoryView = checkmark;
            break;
        }

        case UITableViewCellAccessoryDetailDisclosureButton: {
            UIButton* button = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
            [button addTarget:self action:@selector(_detailDisclosurePressed:) forControlEvents:UIControlEventTouchUpInside];
            _accessoryView = button;
            break;
        }

        case UITableViewCellAccessoryDisclosureIndicator: {
            UIImageView* disclosureIndicator = [[UIImageView alloc] initWithImage:accessoryDisclosureIndicatorImage];
            disclosureIndicator.highlightedImage = accessoryDisclosureIndicatorImageHighlighted;
            _accessoryView = disclosureIndicator;
            break;
        }
    }
    _tableCellFlags.usingDefaultAccessoryView = YES;
    if (_accessoryView) {
        [self.contentView addSubview:_accessoryView];
        [self setNeedsLayout];
    }
}

- (void) _detailDisclosurePressed:(id)sender
{   
    NSLog(@"clicked.");
}

@end