//  Created by Sean Heber on 6/25/10.
#import "UIBarItem.h"

typedef enum {
	UIBarButtonSystemItemDone,
	UIBarButtonSystemItemCancel,
	UIBarButtonSystemItemEdit,
	UIBarButtonSystemItemSave,
	UIBarButtonSystemItemAdd,
	UIBarButtonSystemItemFlexibleSpace,
	UIBarButtonSystemItemFixedSpace,
	UIBarButtonSystemItemCompose,
	UIBarButtonSystemItemReply,
	UIBarButtonSystemItemAction,
	UIBarButtonSystemItemOrganize,
	UIBarButtonSystemItemBookmarks,
	UIBarButtonSystemItemSearch,
	UIBarButtonSystemItemRefresh,
	UIBarButtonSystemItemStop,
	UIBarButtonSystemItemCamera,
	UIBarButtonSystemItemTrash,
	UIBarButtonSystemItemPlay,
	UIBarButtonSystemItemPause,
	UIBarButtonSystemItemRewind,
	UIBarButtonSystemItemFastForward,
	UIBarButtonSystemItemUndo,        // iPhoneOS 3.0
	UIBarButtonSystemItemRedo,        // iPhoneOS 3.0
} UIBarButtonSystemItem;

typedef enum {
	UIBarButtonItemStylePlain,
	UIBarButtonItemStyleBordered,
	UIBarButtonItemStyleDone,
} UIBarButtonItemStyle;

@class UIView, UIImage;

@interface UIBarButtonItem : UIBarItem {
@package
	CGFloat _width;
	UIView *_customView;
	id _target;
	SEL _action;
	BOOL _isSystemItem;
	UIBarButtonSystemItem _systemItem;
	UIBarButtonItemStyle _style;
}

- (id)initWithBarButtonSystemItem:(UIBarButtonSystemItem)systemItem target:(id)target action:(SEL)action;
- (id)initWithCustomView:(UIView *)customView;
- (id)initWithTitle:(NSString *)title style:(UIBarButtonItemStyle)style target:(id)target action:(SEL)action;
- (id)initWithImage:(UIImage *)image style:(UIBarButtonItemStyle)style target:(id)target action:(SEL)action;

@property (nonatomic) UIBarButtonItemStyle style;
@property (nonatomic) CGFloat width;
@property (nonatomic, retain) UIView *customView;
@property (nonatomic, assign) id target;
@property (nonatomic) SEL action;

@end
