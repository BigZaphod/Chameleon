//  Created by Sean Heber on 6/4/10.
#import "UITableViewCell+UIPrivate.h"
#import "_UITableViewCellSeparator.h"
#import "UIColor.h"
#import "UILabel.h"
#import "UIImageView.h"

@implementation UITableViewCell
@synthesize contentView=_contentView, accessoryType=_accessoryType, textLabel=_textLabel, selectionStyle=_selectionStyle, indentationLevel=_indentationLevel;
@synthesize imageView=_imageView, editingAccessoryType=_editingAccessoryType, selected=_selected, backgroundView=_backgroundView;
@synthesize selectedBackgroundView=_selectedBackgroundView, highlighted=_highlighted;

- (id)initWithFrame:(CGRect)frame
{
	if ((self=[super initWithFrame:frame])) {
		_seperatorView = [_UITableViewCellSeparator new];
		[self addSubview:_seperatorView];
		
		_contentView = [UIView new];
		[self addSubview:_contentView];
		
		self.accessoryType = UITableViewCellAccessoryNone;
		self.editingAccessoryType = UITableViewCellAccessoryNone;
	}
	return self;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
	if ((self=[self initWithFrame:CGRectZero])) {
	}
	return self;
}

- (void)dealloc
{
	[_seperatorView release];
	[_contentView release];
	[_textLabel release];
	[_imageView release];
	[_backgroundView release];
	[_selectedBackgroundView release];
	[super dealloc];
}

- (void)layoutSubviews
{
	[super layoutSubviews];

	CGRect bounds = self.bounds;
	BOOL showingSeperator = !_seperatorView.hidden;
	
	CGRect contentFrame = CGRectMake(0,0,bounds.size.width,bounds.size.height-(showingSeperator? 1 : 0));
	
	_backgroundView.frame = contentFrame;
	_selectedBackgroundView.frame = contentFrame;
	_contentView.frame = contentFrame;
	
	[self bringSubviewToFront:_backgroundView];
	[self bringSubviewToFront:_selectedBackgroundView];
	[self bringSubviewToFront:_contentView];
	
	if (showingSeperator) {
		_seperatorView.frame = CGRectMake(0,bounds.size.height-1,bounds.size.width,1);
		[self bringSubviewToFront:_seperatorView];
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
	_selectedBackgroundView.hidden = !shouldHighlight;
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
		self.backgroundColor = [UIColor clearColor];
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

- (UILabel *)textLabel
{
	if (!_textLabel) {
		_textLabel = [UILabel new];
		_textLabel.backgroundColor = [UIColor clearColor];
		[_contentView addSubview:_textLabel];
	}
	return _textLabel;
}

- (UIImageView *)imageView
{
	if (!_imageView) {
		_imageView = [UIImageView new];
		[_contentView addSubview:_imageView];
	}
	return _imageView;
}

@end
