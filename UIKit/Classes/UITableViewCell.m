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
#import "UIImage+UIPrivate.h"

extern CGFloat _UITableViewDefaultRowHeight;

@interface UITableViewCellBackgroundView : UIView
@end

@interface UITableViewCellSelectedBackgroundView : UIView
@end

@implementation UITableViewCellBackgroundView

- (void)drawRect:(CGRect)dirtyRect
{

	float radius = 10.0;
	
	int lineWidth = 1;
	
	CGRect rect = [self bounds];
	
	rect.size.width -= lineWidth;
	rect.size.height -= lineWidth;
	rect.origin.x += lineWidth / 2.0;
	rect.origin.y += lineWidth / 2.0;
	
	CGFloat minX = CGRectGetMinX(rect), midX = CGRectGetMidX(rect), maxX = CGRectGetMaxX(rect);
	CGFloat minY = CGRectGetMinY(rect), maxY = CGRectGetMaxY(rect);
	
	maxY += 1;
	
	CGContextRef c = UIGraphicsGetCurrentContext();
	
	CGContextSetLineWidth(c, lineWidth);
//	CGContextSetAllowsAntialiasing(c, YES);
//	CGContextSetShouldAntialias(c, YES);
	
	
	if ([[self superview ] sectionLocation] == UITableViewCellSectionLocationTop) {
		//minY += 1;
				
		CGContextClearRect(c, [self bounds]);
		CGContextBeginPath(c);
		CGContextMoveToPoint(c, minX,maxY);
		CGContextAddArcToPoint(c,minX, minY, midX, minY, radius);
		CGContextAddArcToPoint(c,maxX, minY, maxX, maxY, radius);
		CGContextAddLineToPoint(c, maxX, maxY);
		CGContextSaveGState(c);
		CGColorRef fillColor = [self.backgroundColor CGColor];
		CGContextSetFillColorWithColor(c, fillColor);
		CGContextSetRGBStrokeColor(c, .67f, .67f, .67f, 1.0);
		
		CGContextDrawPath(c, kCGPathFillStroke);
		CGContextRestoreGState(c);
	}
	else if ([[self superview ] sectionLocation] == UITableViewCellSectionLocationBottom) {
		CGContextSaveGState(c);
		CGContextClearRect(c, [self bounds]);
		CGContextSetRGBStrokeColor(c, .67f, .67f, .67f, 1.0);
		CGContextBeginPath(c);
		CGContextMoveToPoint(c, minX,minY-1.0f);
		CGContextAddArcToPoint(c,minX, maxY-1.0f, midX, maxY, radius);
		CGContextAddArcToPoint(c,maxX, maxY-1.0f, maxX, minY-1.0f, radius);
		CGContextAddLineToPoint(c, maxX, minY-1.0f);
		CGColorRef fillColor = [self.backgroundColor CGColor];
		CGContextSetFillColorWithColor(c, fillColor);
		CGContextDrawPath(c, kCGPathFillStroke);
		CGContextRestoreGState(c);
	}
	else {
		
		
		CGContextSaveGState(c);
		CGContextSetFillColorWithColor(c, [self.backgroundColor CGColor]);
		CGContextFillRect(c, rect);
		CGContextRestoreGState(c);
		
		
		CGContextBeginPath(c);
		CGContextMoveToPoint(c, minX,minY-1.0f);
		CGContextAddLineToPoint(c, minX, maxY);
		CGContextSaveGState(c);
		CGContextSetRGBStrokeColor(c, .67f, .67f, .67f, 1.0);
		CGContextStrokePath(c);
		CGContextRestoreGState(c);
		
		
		CGContextBeginPath(c);
		CGContextMoveToPoint(c, maxX,minY-1.0f);
		CGContextAddLineToPoint(c, maxX, maxY);
		CGContextSaveGState(c);
		CGContextSetRGBStrokeColor(c, .67f, .67f, .67f, 1.0);
		CGContextStrokePath(c);
		CGContextRestoreGState(c);
		
	}
	
	
	
}

@end

@implementation UITableViewCellSelectedBackgroundView

- (void)drawRect:(CGRect)dirtyRect
{

	float radius = 10.0;
	
	int lineWidth = 1;
	
	CGRect rect = [self bounds];
	
	rect.size.width -= lineWidth;
	rect.size.height -= lineWidth;
	rect.origin.x += lineWidth / 2.0;
	rect.origin.y += lineWidth / 2.0;
	
	CGFloat minX = CGRectGetMinX(rect), midX = CGRectGetMidX(rect), maxX = CGRectGetMaxX(rect);
	CGFloat minY = CGRectGetMinY(rect), maxY = CGRectGetMaxY(rect);
	
	maxY += 1;
	
	CGContextRef c = UIGraphicsGetCurrentContext();
	
	CGContextSetLineWidth(c, lineWidth);
	//CGContextSetAllowsAntialiasing(c, YES);
	//CGContextSetShouldAntialias(c, YES);
	
	if ([[self superview] sectionLocation]==UITableViewCellSectionLocationTop) {
		
		CGContextClearRect(c, rect);
		
		CGRect imageRect = self.bounds;

		CGMutablePathRef path = CGPathCreateMutable();
		CGPathMoveToPoint(path, NULL, minX, maxY);
		CGPathAddArcToPoint(path, NULL, minX, minY, midX, minY, radius);
		CGPathAddArcToPoint(path, NULL, maxX, minY, maxX, maxY, radius);
		CGPathAddLineToPoint(path, NULL, maxX, maxY);
		CGPathAddLineToPoint(path, NULL, minX, maxY);
		CGPathCloseSubpath(path);
		CGContextAddPath(c, path);
		CGPathRelease(path);
		
		CGContextSaveGState(c);
		CGContextClip(c);
		UIImage *currentBackgroundImage = nil;
		
		if ([[self superview] selectionStyle]==UITableViewCellSelectionStyleBlue) {
			currentBackgroundImage = [UIImage _tableSelection];
		}
		else {
			currentBackgroundImage = [UIImage _tableSelectionGray];
		}
		[currentBackgroundImage drawInRect:imageRect];
		CGContextRestoreGState(c);
		
		CGMutablePathRef spath = CGPathCreateMutable();
		CGPathMoveToPoint(spath, NULL, minX, maxY);
		CGPathAddArcToPoint(spath, NULL, minX, minY, midX, minY, radius);
		CGPathAddArcToPoint(spath, NULL, maxX, minY, maxX, maxY, radius);
		CGPathAddLineToPoint(spath, NULL, maxX, maxY);
		CGContextAddPath(c, spath);
		CGPathRelease(path);
		CGContextSaveGState(c);
		CGContextSetRGBStrokeColor(c, .67f, .67f, .67f, 1.0);
		CGContextStrokePath(c);
		CGContextRestoreGState(c);
		
	}	
	else if ([[self superview ] sectionLocation]==UITableViewCellSectionLocationBottom) {
		
		CGContextClearRect(c, rect);
		
		CGRect imageRect = self.bounds;
		
		CGMutablePathRef path = CGPathCreateMutable();
		CGPathMoveToPoint(path, NULL, minX, minY-1.0f);
		CGPathAddArcToPoint(path, NULL, minX, maxY-1.0f, midX, maxY-1.0f, radius);
		CGPathAddArcToPoint(path, NULL, maxX, maxY-1.0f, maxX, minY-1.0f, radius);
		CGPathAddLineToPoint(path, NULL, maxX, minY-1.0f);
		CGPathAddLineToPoint(path, NULL, minX, minY-1.0f);
		CGPathCloseSubpath(path);
		CGContextAddPath(c, path);
		CGPathRelease(path);
		CGContextSaveGState(c);
		CGContextClip(c);
		UIImage *currentBackgroundImage = nil;
		if ([[self superview] selectionStyle] == UITableViewCellSelectionStyleBlue) {
			currentBackgroundImage = [UIImage _tableSelection];
		}
		else {
			currentBackgroundImage = [UIImage _tableSelectionGray];
		}
		[currentBackgroundImage drawInRect:imageRect];
		CGContextRestoreGState(c);
		
		CGContextBeginPath(c);
		CGContextMoveToPoint(c, minX,minY-1.0f);
		CGContextAddArcToPoint(c,minX, maxY-1.0f, midX, maxY, radius);
		CGContextAddArcToPoint(c,maxX, maxY-1.0f, maxX, minY-1.0f, radius);
		CGContextAddLineToPoint(c, maxX, minY-1.0f);
		CGContextSaveGState(c);
		CGContextSetRGBStrokeColor(c, .67f, .67f, .67f, 1.0);
		CGContextStrokePath(c);
		CGContextRestoreGState(c);
		
	}
	else {
		
		CGContextSaveGState(c);

		CGRect imageRect = self.bounds;
		
		UIImage *currentBackgroundImage = nil;
		if ([[self superview] selectionStyle] == UITableViewCellSelectionStyleBlue) {
			currentBackgroundImage = [UIImage _tableSelection];
		}
		else {
			currentBackgroundImage = [UIImage _tableSelectionGray];
		}
		[currentBackgroundImage drawInRect:imageRect];
		CGContextRestoreGState(c);
		
		CGContextBeginPath(c);
		CGContextMoveToPoint(c, minX,minY-1.0f);
		CGContextAddLineToPoint(c, minX, maxY+1.0f);
		
		CGContextSaveGState(c);
		CGContextSetRGBStrokeColor(c, .67f, .67f, .67f, 1.0);
		CGContextStrokePath(c);
		CGContextRestoreGState(c);
		
		CGContextBeginPath(c);
		CGContextMoveToPoint(c, maxX,minY-1.0f);
		CGContextAddLineToPoint(c, maxX, maxY+1.0f);
		
		CGContextSaveGState(c);
		CGContextSetRGBStrokeColor(c, .67f, .67f, .67f, 1.0);
		CGContextStrokePath(c);
		CGContextRestoreGState(c);
		
	}
}
@end

@implementation UITableViewCell
@synthesize contentView=_contentView, accessoryType=_accessoryType, textLabel=_textLabel, selectionStyle=_selectionStyle, indentationLevel=_indentationLevel;
@synthesize imageView=_imageView, editingAccessoryType=_editingAccessoryType, selected=_selected, backgroundView=_backgroundView;
@synthesize selectedBackgroundView=_selectedBackgroundView, highlighted=_highlighted, reuseIdentifier=_reuseIdentifier;
@synthesize editing = _editing, detailTextLabel = _detailTextLabel, showingDeleteConfirmation = _showingDeleteConfirmation;
@synthesize indentationWidth=_indentationWidth, accessoryView=_accessoryView;
@synthesize sectionLocation=_sectionLocation;
@synthesize tableViewStyle;



- (id)initWithFrame:(CGRect)frame
{
	if ((self=[super initWithFrame:frame])) {
        _indentationWidth = 10;
		_style = UITableViewCellStyleDefault;
		
		_seperatorView = [[UITableViewCellSeparator alloc] init];
		[self addSubview:_seperatorView];
		
		_contentView = [[UIView alloc] init];
		_contentView.backgroundColor=[UIColor clearColor];
		[self addSubview:_contentView];
		
		_imageView = [[UIImageView alloc] init];
		_imageView.contentMode = UIViewContentModeCenter;
		[_contentView addSubview:_imageView];
		
		_textLabel = [[UILabel alloc] init];
		_textLabel.backgroundColor = [UIColor clearColor];
		_textLabel.textColor = [UIColor blackColor];
		_textLabel.highlightedTextColor = [UIColor whiteColor];
		_textLabel.font = [UIFont boldSystemFontOfSize:17];
		[_contentView addSubview:_textLabel];
		
		if (_style = UITableViewCellStyleSubtitle) {
			_detailTextLabel = [[UILabel alloc] init];
			_detailTextLabel.backgroundColor = [UIColor clearColor];
			_detailTextLabel.textColor = [UIColor grayColor];
			_detailTextLabel.highlightedTextColor = [UIColor whiteColor];
			_detailTextLabel.font = [UIFont boldSystemFontOfSize:14];
			[_contentView addSubview:_detailTextLabel];
		}
		
		self.backgroundColor = [UIColor whiteColor];
		self.accessoryType = UITableViewCellAccessoryNone;
		self.editingAccessoryType = UITableViewCellAccessoryNone;
		self.selectionStyle = UITableViewCellSelectionStyleBlue;
	}
	return self;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
	if ((self=[self initWithFrame:CGRectMake(0,0,320,_UITableViewDefaultRowHeight)])) {
		_style = style;
		_reuseIdentifier = [reuseIdentifier copy];
	}
	return self;
}

- (void)dealloc
{
	[_seperatorView release];
	[_contentView release];
    [_accessoryView release];
	[_textLabel release];
    [_detailTextLabel release];
	[_imageView release];
	[_backgroundView release];
	[_selectedBackgroundView release];
	[_accessoryView release];
	[_reuseIdentifier release];
	
	[super dealloc];
}

- (void)layoutSubviews
{
	
	[super layoutSubviews];
	
	CGRect bounds = self.bounds;
	BOOL showingSeperator = !_seperatorView.hidden;
	
	CGRect contentFrame = CGRectMake(0,0,bounds.size.width,bounds.size.height-(showingSeperator? 1 : 0));
	
	CGRect accessoryRect = CGRectMake(bounds.size.width, 0, 0, 0);
	if(_accessoryView) {
		accessoryRect.size = [_accessoryView sizeThatFits: bounds.size];
		accessoryRect.origin.x = bounds.size.width - accessoryRect.size.width;
		accessoryRect.origin.y = round(0.5*(bounds.size.height - accessoryRect.size.height));
		_accessoryView.frame = accessoryRect;
		if(_accessoryView.superview != self)
			[self addSubview: _accessoryView];
		contentFrame.size.width = accessoryRect.origin.x - 1;
	}
		
	if (self.tableViewStyle == 1) {
		
		if (self.isSelected == YES) {
			if (self.selectedBackgroundView == nil) {
				self.backgroundColor = [UIColor clearColor];
				self.contentView.backgroundColor = [UIColor clearColor];
				self.contentView.opaque = NO;
				self.selectedBackgroundView = [[UITableViewCellSelectedBackgroundView alloc] init];
				self.selectedBackgroundView.backgroundColor = [UIColor clearColor];
				self.selectedBackgroundView.opaque = NO;
				[self bringSubviewToFront:_selectedBackgroundView];
			}
			else {
				[self.backgroundView setHidden:YES];
				[self.selectedBackgroundView setHidden:NO];
				[self.selectedBackgroundView setNeedsDisplay];
			}
			
		}
		else
		{
			if (self.backgroundView == nil) {
				self.contentView.backgroundColor = [UIColor clearColor];
				self.contentView.opaque = NO;
				self.backgroundView = [[UITableViewCellBackgroundView alloc] init];
				self.backgroundView.opaque = NO;
				[self bringSubviewToFront:_backgroundView];
			}
			else {
				[self.selectedBackgroundView setHidden:YES];
				[self.backgroundView setHidden:NO];
				[self.backgroundView setNeedsDisplay];
			}
		}
		
		if (self.backgroundColor != [UIColor clearColor]) {
			_backgroundView.backgroundColor = self.backgroundColor;
			self.backgroundColor = [UIColor clearColor];
			_contentView.opaque = NO;
			_backgroundView.opaque = NO;
		}
	}
	
	_backgroundView.frame = contentFrame;
	
	_selectedBackgroundView.frame = contentFrame;
	
	_contentView.frame = contentFrame;
	
	[self bringSubviewToFront:_contentView];
	
	
	if (showingSeperator) {
		_seperatorView.frame = CGRectMake(0,bounds.size.height-1,bounds.size.width,1);
		[self bringSubviewToFront:_seperatorView];
	}
	
	if (_style == UITableViewCellStyleDefault) {
		const CGFloat padding = 5;
		
		BOOL showImage = (_imageView.image != nil);
		_imageView.frame = CGRectMake(padding,0,(showImage? 30:0),contentFrame.size.height);
		
		CGRect textRect;
		textRect.origin = CGPointMake(padding+_imageView.frame.size.width+padding,0);
		textRect.size = CGSizeMake(MAX(0,contentFrame.size.width-textRect.origin.x-padding),contentFrame.size.height);
		_textLabel.frame = textRect;
	}
	
	if (_style == UITableViewCellStyleSubtitle) {
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

- (void)drawRect:(CGRect)rect
{
	/*******
	 some of the code from Mike Akers
	 http://stackoverflow.com/questions/400965/how-to-customize-the-background-border-colors-of-a-grouped-table-view
	 *******/
	
    const CGRect bounds = self.bounds;
	
    if (self.tableViewStyle == 0) {
        CGContextRef c = UIGraphicsGetCurrentContext();
        
		if (self.isSelected == YES) {
			
            if (self.selectionStyle == UITableViewCellSelectionStyleBlue) {
				
                UIImage *currentBackgroundImage = nil;
				currentBackgroundImage = [UIImage _tableSelection];
				
				CGContextSaveGState(c);
				[currentBackgroundImage drawInRect:bounds];
				CGContextRestoreGState(c);
			}
			
			if (self.selectionStyle == UITableViewCellSelectionStyleGray) {
				
				UIImage *currentBackgroundImage = nil;
				currentBackgroundImage = [UIImage _tableSelectionGray];
				
				CGContextSaveGState(c);
				[currentBackgroundImage drawInRect:bounds];
				CGContextRestoreGState(c);
			}
		}
		
	}
	else {
			[self setNeedsLayout];
	}
}

- (void)_setSeparatorStyle:(UITableViewCellSeparatorStyle)theStyle color:(UIColor *)theColor
{
	[_seperatorView setSeparatorStyle:theStyle color:theColor];
}

- (void)_setHighlighted:(BOOL)highlighted forViews:(id)subviews
{
	for (id view in subviews) {
		if ([view respondsToSelector:@selector(setHighlighted:)]) {
			[view setHighlighted:highlighted];
		}
		[self _setHighlighted:highlighted forViews:[view subviews]];
	}
}

- (void)_updateSelectionState
{
	BOOL shouldHighlight = (_highlighted || _selected);
	
	[self setNeedsLayout];
	[self setNeedsDisplay];
	[self _setHighlighted:shouldHighlight forViews:[self subviews]];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
	if (selected != _selected) {
		_selected = selected;
		[self _updateSelectionState];
	}
}

- (void)setSelected:(BOOL)selected
{
	[self setSelected:selected animated:NO];
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
	if (_highlighted != highlighted) {
		_highlighted = highlighted;
		[self _updateSelectionState];
	}
}

- (void)setHighlighted:(BOOL)highlighted
{
	[self setHighlighted:highlighted animated:NO];
}


- (void)setBackgroundView:(UIView *)theBackgroundView
{
	if (theBackgroundView != _backgroundView) {
		[_backgroundView removeFromSuperview];
		[_backgroundView release];
		_backgroundView = [theBackgroundView retain];
		[self addSubview:_backgroundView];
	}
}

- (void)setSelectedBackgroundView:(UIView *)theSelectedBackgroundView
{
	if (theSelectedBackgroundView != _selectedBackgroundView) {
		[_selectedBackgroundView removeFromSuperview];
		[_selectedBackgroundView release];
		_selectedBackgroundView = [theSelectedBackgroundView retain];
		_selectedBackgroundView.hidden = !_selected;
		[self addSubview:_selectedBackgroundView];
	}
}


- (void)prepareForReuse
{
}

@end