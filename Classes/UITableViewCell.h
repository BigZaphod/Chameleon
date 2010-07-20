//  Created by Sean Heber on 6/4/10.
#import "UIView.h"

typedef enum {
	UITableViewCellAccessoryNone,
	UITableViewCellAccessoryDisclosureIndicator,
	UITableViewCellAccessoryDetailDisclosureButton,
	UITableViewCellAccessoryCheckmark
} UITableViewCellAccessoryType;

typedef enum {
	UITableViewCellSeparatorStyleNone,
	UITableViewCellSeparatorStyleSingleLine,
	UITableViewCellSeparatorStyleSingleLineEtched
} UITableViewCellSeparatorStyle;

typedef enum {
	UITableViewCellStyleDefault,
	UITableViewCellStyleValue1,
	UITableViewCellStyleValue2,
	UITableViewCellStyleSubtitle
} UITableViewCellStyle;

typedef enum {
	UITableViewCellSelectionStyleNone,
	UITableViewCellSelectionStyleBlue,
	UITableViewCellSelectionStyleGray
} UITableViewCellSelectionStyle;

@class _UITableViewCellSeparator, UILabel, UIImageView;

@interface UITableViewCell : UIView {
@private
	_UITableViewCellSeparator *_seperatorView;
	UIView *_contentView;
	UILabel *_textLabel;
	UIImageView *_imageView;
	UIView *_backgroundView;
	UIView *_selectedBackgroundView;
	UITableViewCellAccessoryType _accessoryType;
	UITableViewCellAccessoryType _editingAccessoryType;
	UITableViewCellSelectionStyle _selectionStyle;
	NSInteger _indentationLevel;
	BOOL _selected;
	BOOL _highlighted;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier;
- (void)setSelected:(BOOL)selected animated:(BOOL)animated;

@property (nonatomic, readonly, retain) UIView *contentView;
@property (nonatomic, readonly, retain) UILabel *textLabel;
@property (nonatomic, readonly, retain) UIImageView *imageView;
@property (nonatomic, retain) UIView *backgroundView;
@property (nonatomic, retain) UIView *selectedBackgroundView;
@property (nonatomic) UITableViewCellSelectionStyle selectionStyle;
@property (nonatomic) NSInteger indentationLevel;
@property (nonatomic) UITableViewCellAccessoryType accessoryType;
@property (nonatomic) UITableViewCellAccessoryType editingAccessoryType;
@property (nonatomic, getter=isSelected) BOOL selected;
@property (nonatomic, getter=isHighlighted) BOOL highlighted;

@end
