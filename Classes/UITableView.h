//  Created by Sean Heber on 6/4/10.
#import "UIScrollView.h"
#import "UITableViewCell.h"
#import "NSIndexPath+UITableView.h"

@class UITableView;

@protocol UITableViewDelegate <UIScrollViewDelegate>
@optional
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
@end

@protocol UITableViewDataSource <NSObject>
@required
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
@optional
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView;
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

@interface UITableView : UIScrollView {
@private
	UITableViewStyle _style;
	id<UITableViewDataSource> _dataSource;
	BOOL _needsReload;
	CGFloat _rowHeight;
	UIColor *_separatorColor;
	UITableViewCellSeparatorStyle _separatorStyle;
	NSMutableDictionary *_cellHeights;
	NSMutableDictionary *_cellOffsets;
	NSMutableDictionary *_activeCells;
	UIView *_tableHeaderView;
	UIView *_tableFooterView;
	BOOL _allowsSelection;
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
- (CGRect)rectForRowAtIndexPath:(NSIndexPath *)indexPath;

- (NSIndexPath *)indexPathForSelectedRow;
- (void)deselectRowAtIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated;
- (void)selectRowAtIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated scrollPosition:(UITableViewScrollPosition)scrollPosition;
- (void)scrollToNearestSelectedRowAtScrollPosition:(UITableViewScrollPosition)scrollPosition animated:(BOOL)animated;
- (void)scrollToRowAtIndexPath:(NSIndexPath *)indexPath atScrollPosition:(UITableViewScrollPosition)scrollPosition animated:(BOOL)animated;

@property (nonatomic, readonly) UITableViewStyle style;
@property (nonatomic, assign) id<UITableViewDelegate> delegate;
@property (nonatomic, assign) id<UITableViewDataSource> dataSource;
@property (nonatomic) CGFloat rowHeight;
@property (nonatomic) UITableViewCellSeparatorStyle separatorStyle;
@property (nonatomic, retain) UIColor *separatorColor;
@property (nonatomic, retain) UIView *tableHeaderView;
@property (nonatomic, retain) UIView *tableFooterView;
@property (nonatomic) BOOL allowsSelection;

@end

