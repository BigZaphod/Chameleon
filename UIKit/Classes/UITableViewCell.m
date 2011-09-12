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
#import "UITableViewCellUnhighlightedState.h"
#import "UITableViewCellSeparator.h"
#import "UIColor.h"
#import "UILabel.h"
#import "UIImageView.h"
#import "UIFont.h"
#import "UIGraphics.h"
#import "UITableView.h"
#import "UITableView+UIPrivate.h"
#import "UITableViewCellBackgroundView.h"
#import "UITableViewCellSelectedBackgroundView.h"
#import "UITableViewCellLayoutManager.h"


static NSString* const kUIContentViewKey = @"UIContentView";
static NSString* const kUIDetailTextLabelKey = @"UIDetailTextLabel";
static NSString* const kUIImageViewKey = @"UIImageView";
static NSString* const kUIReuseIdentifierKey = @"UIReuseIdentifier";


extern CGFloat _UITableViewDefaultRowHeight;

@interface UITableViewCell ()
- (UITableViewCellLayoutManager*) layoutManager;
- (void) _setSeparatorStyle:(UITableViewCellSeparatorStyle)theStyle color:(UIColor*)theColor;
- (void) _setTableViewStyle:(NSUInteger)tableViewStyle;
- (void) showSelectedBackgroundView:(BOOL)selected animated:(BOOL)animated;
- (void) _setupDefaultSelectedBackgroundView;
- (void) _setupDefaultAccessoryView;
@end


@implementation UITableViewCell 
@synthesize accessoryType=_accessoryType; 
@synthesize accessoryView=_accessoryView;
@synthesize backgroundView=_backgroundView;
@synthesize contentView=_contentView;
@synthesize detailTextLabel = _detailTextLabel;
@synthesize editing = _editing;
@synthesize editingAccessoryType=_editingAccessoryType;
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

static Class kUIButtonClass;

+ (void) initialize
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSBundle* bundle = [NSBundle bundleForClass:[self class]];
        accessoryCheckmarkImage = [[UIImage imageWithContentsOfFile:[bundle pathForImageResource:@"<UITableViewCell> accessoryCheckmark"]] retain];
        accessoryCheckmarkImageHighlighted = [[UIImage imageWithContentsOfFile:[bundle pathForImageResource:@"<UITableViewCell> accessoryCheckmarkHighlighted"]] retain];
        accessoryDisclosureIndicatorImage = [[UIImage imageWithContentsOfFile:[bundle pathForImageResource:@"<UITableViewCell> accessoryDisclosureIndicator"]] retain];
        accessoryDisclosureIndicatorImageHighlighted = [[UIImage imageWithContentsOfFile:[bundle pathForImageResource:@"<UITableViewCell> accessoryDisclosureIndicatorHighlighted"]] retain];
        kUIButtonClass = [UIButton class];
    });
}

- (void) dealloc
{
    if (_unhighlightedStates) {
        CFRelease(_unhighlightedStates);
    }
	[_separatorView release];
	[_contentView release];
    [_accessoryView release];
	[_textLabel release];
    [_detailTextLabel release];
	[_imageView release];
	[_backgroundView release];
	[_selectedBackgroundView release];
	[_reuseIdentifier release];
	[_layoutManager release];
    
	[super dealloc];
}

- (void) _commonInitForUITableViewCell
{
    _indentationWidth = 10;
    _style = UITableViewCellStyleDefault;
    _accessoryType = UITableViewCellAccessoryNone;
    _editingAccessoryType = UITableViewCellAccessoryNone;
    _selectionStyle = UITableViewCellSelectionStyleBlue;
}

- (void) _configureContentViewAndLayoutManager
{
    _layoutManager = [[UITableViewCellLayoutManager layoutManagerForTableViewCellStyle:_style] retain];
    if (!_contentView) {
        _contentView = [[UIView alloc] init];
        _contentView.frame = [_layoutManager contentViewRectForCell:self];
    }
    [self addSubview:_contentView];
}

- (id) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString*)reuseIdentifier
{
	if (nil != (self = [super initWithFrame:CGRectMake(0,0,320,_UITableViewDefaultRowHeight)])) {
        [self _commonInitForUITableViewCell];
		_style = style;
		_reuseIdentifier = [reuseIdentifier copy];
        [self _configureContentViewAndLayoutManager];
	}
	return self;
}

- (id) initWithFrame:(CGRect)frame
{
	if (nil != (self = [super initWithFrame:frame])) {
        [self _commonInitForUITableViewCell];
        [self _configureContentViewAndLayoutManager];
        
	}
	return self;
}

- (id) initWithCoder:(NSCoder*)coder
{
    if (nil != (self = [super initWithCoder:coder])) {
        [self _commonInitForUITableViewCell];
        _reuseIdentifier = [[coder decodeObjectForKey:kUIReuseIdentifierKey] retain];
        _contentView = [[coder decodeObjectForKey:kUIContentViewKey] retain];
        _detailTextLabel = [[coder decodeObjectForKey:kUIDetailTextLabelKey] retain];
        _imageView = [[coder decodeObjectForKey:kUIImageViewKey] retain];
        [self _configureContentViewAndLayoutManager];
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
            _accessoryView.frame = [_layoutManager accessoryViewRectForCell:self];
            [self addSubview:_accessoryView];
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
        _contentView.frame = [_layoutManager contentViewRectForCell:self];
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
    if (_tableCellFlags.usingDefaultSelectedBackgroundView) {
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
            if (self.isHighlighted) {
                if (_backgroundView) {
                    [self insertSubview:_selectedBackgroundView aboveSubview:_backgroundView];
                } else {
                    [self insertSubview:_selectedBackgroundView atIndex:0];
                }
                [self setNeedsLayout];
            }
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

- (BOOL) isHighlighted
{
    return _tableCellFlags.highlighted;
}

- (void) setHighlighted:(BOOL)highlighted
{
	[self setHighlighted:highlighted animated:NO];
}

- (void) setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    [self showSelectedBackgroundView:highlighted animated:animated];
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
        
	if (_accessoryView) {
        _accessoryView.frame = [_layoutManager accessoryViewRectForCell:self];
	}
	if (_backgroundView) {
        _backgroundView.frame = [_layoutManager backgroundViewRectForCell:self];
	}
    if (_selectedBackgroundView) {
        _selectedBackgroundView.frame = [_layoutManager backgroundViewRectForCell:self];
    }
    if (_contentView) {
        _contentView.frame = [_layoutManager contentViewRectForCell:self];
	}
	if (_separatorView) {
		_separatorView.frame = [_layoutManager seperatorViewRectForCell:self];
	}
    if (_imageView) {
        _imageView.frame = [_layoutManager imageViewRectForCell:self];
    }
    if (_textLabel) {
        _textLabel.frame = [_layoutManager textLabelRectForCell:self];
    }
    if (_detailTextLabel) {
        _detailTextLabel.frame = [_layoutManager detailTextLabelRectForCell:self];
	}
}


#pragma mark Internals

- (UITableViewCellLayoutManager*) layoutManager
{
    return _layoutManager;
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
                _separatorView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
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

- (void) _saveOpaqueViewState:(UIView*)view
{
    if (![view isKindOfClass:[UITableViewCell class]]) {
        UITableViewCellUnhighlightedState* state = [[UITableViewCellUnhighlightedState alloc] init];
        state.highlighted = [view respondsToSelector:@selector(isHighlighted)] ? [(id)view isHighlighted] : NO;
        state.opaque = [view isOpaque];
        state.backgroundColor = view.backgroundColor;
        CFDictionarySetValue(_unhighlightedStates, view, state);
        [state release];
    }
    for (UIView* subview in view.subviews) {
        [self _saveOpaqueViewState:subview];
    }
}

- (void) _clearOpaqueViewState:(UIView*)view
{
    UITableViewCellUnhighlightedState* state;
    if (CFDictionaryGetValueIfPresent(_unhighlightedStates, view, (const void**)&state)) {
        if ([view respondsToSelector:@selector(setHighlighted:)]) {
            [(id)view setHighlighted:state.highlighted];
        }
        view.opaque = state.opaque;
        view.backgroundColor = state.backgroundColor;
    }
    for (UIView* subview in view.subviews) {
        [self _clearOpaqueViewState:subview];
    }
}

- (void) _setOpaque:(BOOL)opaque forSubview:(UIView*)view
{
    if (view != _selectedBackgroundView) {
        view.opaque = opaque;
        view.backgroundColor = opaque ? [UIColor whiteColor] : [UIColor clearColor];
    }
    for (UIView* subview in view.subviews) {
        [self _setOpaque:opaque forSubview:subview];
    }
}

- (void) _updateHighlightColorsForView:(UIView*)view highlighted:(BOOL)highlighted
{
    if (([view class] != kUIButtonClass)
     && (![view isKindOfClass:[UITableViewCell class]]) 
     && ([view respondsToSelector:@selector(setHighlighted:)] && [view respondsToSelector:@selector(isHighlighted)])
    ) {
        [(id)view setHighlighted:highlighted];
    }
    for (UIView* subview in view.subviews) {
        [self _updateHighlightColorsForView:subview highlighted:highlighted];
    }
}

- (void) _updateHighlightColors
{
    [self _updateHighlightColorsForView:self highlighted:_tableCellFlags.highlighted];
}

- (void) showSelectedBackgroundView:(BOOL)selected animated:(BOOL)animated
{
    if (_selectionStyle != UITableViewCellSelectionStyleNone && _tableCellFlags.highlighted != selected) {
        _tableCellFlags.highlighted = selected;

        if (selected) {
            if (!_selectedBackgroundView) {
                [self _setupDefaultSelectedBackgroundView];
            }
            if (_backgroundView) {
                [self insertSubview:_selectedBackgroundView aboveSubview:_backgroundView];
            } else {
                [self insertSubview:_selectedBackgroundView atIndex:0];
            }
        
            assert(!_unhighlightedStates);
            _unhighlightedStates = CFDictionaryCreateMutable(NULL, 0, NULL, &kCFTypeDictionaryValueCallBacks);
            [self _saveOpaqueViewState:self];

            [self _setOpaque:NO forSubview:self];

            [self _updateHighlightColors];
        } else {
            [_selectedBackgroundView removeFromSuperview];
            if (_tableCellFlags.usingDefaultSelectedBackgroundView) {
                [_selectedBackgroundView release], _selectedBackgroundView = nil;
                _tableCellFlags.usingDefaultSelectedBackgroundView = NO;
            }
            
            [self _updateHighlightColors];
            
            [self _setOpaque:YES forSubview:self];

            assert(_unhighlightedStates);
            [self _clearOpaqueViewState:self];
            CFRelease(_unhighlightedStates), _unhighlightedStates = nil;
        }
        
        [self setNeedsLayout];
    }
}

- (void) _setupDefaultSelectedBackgroundView
{
    assert(!_selectedBackgroundView);
    assert(!_tableCellFlags.usingDefaultSelectedBackgroundView);
    _tableCellFlags.usingDefaultSelectedBackgroundView = YES;
    UITableViewCellSelectedBackgroundView* selectedBackgroundView = [[UITableViewCellSelectedBackgroundView alloc] initWithFrame:self.bounds];
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
            UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.userInteractionEnabled = NO;
            [button setImage:accessoryCheckmarkImage forState:UIControlStateNormal];
            [button setImage:accessoryCheckmarkImageHighlighted forState:UIControlStateHighlighted];
            _accessoryView = [button retain];
            break;
        }

        case UITableViewCellAccessoryDetailDisclosureButton: {
            UIButton* button = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
            [button addTarget:self action:@selector(_detailDisclosurePressed:) forControlEvents:UIControlEventTouchUpInside];
            _accessoryView = [button retain];
            break;
        }

        case UITableViewCellAccessoryDisclosureIndicator: {
            UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.userInteractionEnabled = NO;
            [button setImage:accessoryDisclosureIndicatorImage forState:UIControlStateNormal];
            [button setImage:accessoryDisclosureIndicatorImageHighlighted forState:UIControlStateHighlighted];
            _accessoryView = [button retain];
            break;
        }
    }
    _tableCellFlags.usingDefaultAccessoryView = YES;
    if (_accessoryView) {
        [self addSubview:_accessoryView];
        [self setNeedsLayout];
    }
}

- (void) _detailDisclosurePressed:(id)sender
{   
    [(UITableView*)[self superview] _accessoryButtonTappedForTableViewCell:self];
}

-(void)encodeWithCoder:(NSCoder *)aCoder {
    //TODO:later
}

@end
