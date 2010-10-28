//  Created by Sean Heber on 6/4/10.
#import "UIScrollView.h"
#import "UITableViewCell.h"
#import "NSIndexPath+UITableView.h"

@class UITableView;

@protocol UITableViewDelegate <UIScrollViewDelegate>
@optional
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
- (NSIndexPath *)tableView:(UITableView *)tableView willDeselectRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath;

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section;
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section;
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section;
- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section;
@end

@protocol UITableViewDataSource <NSObject>
@required
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
@optional
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView;
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section;
- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section;
@end

typedef enum {
	UITableViewStylePlain,
	UITableViewStyleGrouped
} UITableViewStyle;

typedef enum {
	UITableViewScrollPositionNone,
	UITableViewScrollPositionTop,
	UITableViewScrollPositionMiddle,
	UITableViewScrollPositionBottom
} UITableViewScrollPosition;

typedef enum {
	UITableViewRowAnimationFade,
	UITableViewRowAnimationRight,
	UITableViewRowAnimationLeft,
	UITableViewRowAnimationTop,
	UITableViewRowAnimationBottom,
	UITableViewRowAnimationNone,
	UITableViewRowAnimationMiddle
} UITableViewRowAnimation;

@interface UITableView : UIScrollView {
@private
	UITableViewStyle _style;
	id<UITableViewDataSource> _dataSource;
	BOOL _needsReload;
	BOOL _needsCellLayout;
	CGFloat _rowHeight;
	UIColor *_separatorColor;
	UITableViewCellSeparatorStyle _separatorStyle;
	UIView *_tableHeaderView;
	UIView *_tableFooterView;
	BOOL _allowsSelection;
	BOOL _editing;
	NSIndexPath *_selectedRow;
	NSMutableDictionary *_cachedCells;
	NSMutableSet *_reusableCells;
	NSMutableArray *_sections;
	CGFloat _sectionHeaderHeight;
	CGFloat _sectionFooterHeight;
	
	struct {
		BOOL heightForRowAtIndexPath : 1;
		BOOL heightForHeaderInSection : 1;
		BOOL heightForFooterInSection : 1;
		BOOL viewForHeaderInSection : 1;
		BOOL viewForFooterInSection : 1;
		BOOL willSelectRowAtIndexPath : 1;
		BOOL didSelectRowAtIndexPath : 1;
		BOOL willDeselectRowAtIndexPath : 1;
		BOOL didDeselectRowAtIndexPath : 1;
	} _delegateHas;
	
	struct {
		BOOL numberOfSectionsInTableView : 1;
		BOOL titleForHeaderInSection : 1;
		BOOL titleForFooterInSection : 1;
	} _dataSourceHas;
}

- (id)initWithFrame:(CGRect)frame style:(UITableViewStyle)style;
- (void)reloadData;
- (NSInteger)numberOfSections;
- (NSInteger)numberOfRowsInSection:(NSInteger)section;
- (NSArray *)indexPathsForRowsInRect:(CGRect)rect;
- (NSIndexPath *)indexPathForRowAtPoint:(CGPoint)point;
- (NSIndexPath *)indexPathForCell:(UITableViewCell *)cell;
- (NSArray *)indexPathsForVisibleRows;
- (NSArray *)visibleCells;
- (UITableViewCell *)dequeueReusableCellWithIdentifier:(NSString *)identifier;
- (UITableViewCell *)cellForRowAtIndexPath:(NSIndexPath *)indexPath;

- (CGRect)rectForSection:(NSInteger)section;
- (CGRect)rectForHeaderInSection:(NSInteger)section;
- (CGRect)rectForFooterInSection:(NSInteger)section;
- (CGRect)rectForRowAtIndexPath:(NSIndexPath *)indexPath;

- (void)insertRowsAtIndexPaths:(NSArray *)indexPaths withRowAnimation:(UITableViewRowAnimation)animation;	// not implemented
- (void)deleteRowsAtIndexPaths:(NSArray *)indexPaths withRowAnimation:(UITableViewRowAnimation)animation;	// not implemented

- (NSIndexPath *)indexPathForSelectedRow;
- (void)deselectRowAtIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated;
- (void)selectRowAtIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated scrollPosition:(UITableViewScrollPosition)scrollPosition;

// the scrollPosition parameter is currently ignored
- (void)scrollToNearestSelectedRowAtScrollPosition:(UITableViewScrollPosition)scrollPosition animated:(BOOL)animated;
- (void)scrollToRowAtIndexPath:(NSIndexPath *)indexPath atScrollPosition:(UITableViewScrollPosition)scrollPosition animated:(BOOL)animated;

- (void)setEditing:(BOOL)editing animated:(BOOL)animate;

@property (nonatomic, readonly) UITableViewStyle style;
@property (nonatomic, assign) id<UITableViewDelegate> delegate;
@property (nonatomic, assign) id<UITableViewDataSource> dataSource;
@property (nonatomic) CGFloat rowHeight;
@property (nonatomic) UITableViewCellSeparatorStyle separatorStyle;
@property (nonatomic, retain) UIColor *separatorColor;
@property (nonatomic, retain) UIView *tableHeaderView;
@property (nonatomic, retain) UIView *tableFooterView;
@property (nonatomic) BOOL allowsSelection;
@property (nonatomic, getter=isEditing) BOOL editing;
@property (nonatomic) CGFloat sectionHeaderHeight;
@property (nonatomic) CGFloat sectionFooterHeight;

@end

