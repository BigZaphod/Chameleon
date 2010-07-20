//  Created by Sean Heber on 6/4/10.
#import "UITableView.h"
#import "UIColor.h"
#import "UIKit+Private.h"

static const CGFloat kDefaultRowHeight = 43;

@interface UITableView ()
- (void)_setNeedsReload;
@end

@implementation UITableView
@synthesize style=_style, dataSource=_dataSource, rowHeight=_rowHeight, separatorStyle=_separatorStyle, separatorColor=_separatorColor;
@synthesize tableHeaderView=_tableHeaderView, tableFooterView=_tableFooterView, allowsSelection=_allowsSelection;
@dynamic delegate;

- (id)initWithFrame:(CGRect)frame
{
	return [self initWithFrame:frame style:UITableViewStylePlain];
}

- (id)initWithFrame:(CGRect)frame style:(UITableViewStyle)theStyle
{
	if ((self=[super initWithFrame:frame])) {
		_cellHeights = [NSMutableDictionary new];
		_cellOffsets = [NSMutableDictionary new];
		_activeCells = [NSMutableDictionary new];
		_style = theStyle;

		self.separatorColor = [UIColor colorWithRed:.88f green:.88f blue:.88f alpha:1];
		self.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
		self.showsHorizontalScrollIndicator = NO;
		self.allowsSelection = YES;

		if (_style == UITableViewStylePlain) {
			self.backgroundColor = [UIColor whiteColor];
		}
		
		[self _setNeedsReload];
	}
	return self;
}

- (void)dealloc
{
	[_cellHeights release];
	[_cellOffsets release];
	[_activeCells release];
	[_tableFooterView release];
	[_tableHeaderView release];
	[super dealloc];
}

- (void)setDataSource:(id<UITableViewDataSource>)newSource
{
	_dataSource = newSource;
	[self _setNeedsReload];
}

- (void)setRowHeight:(CGFloat)newHeight
{
	_rowHeight = newHeight;
	[self setNeedsLayout];
}

- (void)_setNeedsReload
{
	_needsReload = YES;
	[self setNeedsLayout];
}

- (CGRect)rectForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSNumber *cellOffset = [_cellOffsets objectForKey:indexPath];
	NSNumber *cellHeight = [_cellHeights objectForKey:indexPath];
	
	if (!cellHeight || !cellHeight) {
		return CGRectZero;
	} else {
		return CGRectMake(0,[cellOffset floatValue],self.bounds.size.width-_UIScrollViewScrollerSize-self.scrollIndicatorInsets.right,[cellHeight floatValue]);
	}
}

- (UITableViewCell *)cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	// this is allowed to return nil if the cell isn't visible and is not restricted to only returning visible cells
	// so this simple call should be good enough.
	return [_activeCells objectForKey:indexPath];
}

- (NSArray *)indexPathsForRowsInRect:(CGRect)rect
{
	// This needs to return the index paths even if the cells don't exist in any caches or are not on screen
	// For now I'm assuming the cells stretch all the way across the view. It's not clear to me if the real
	// implementation gets anal about this or not (haven't tested it).
	
	NSMutableArray *results = nil;
	
	if (CGRectContainsRect(self.bounds, rect)) {
		results = [[NSMutableArray new] autorelease];
		
		for (NSIndexPath *index in [_cellOffsets allKeys]) {
			CGFloat offset = [[_cellOffsets objectForKey:index] floatValue];
			if (CGRectContainsPoint(rect,CGPointMake(rect.origin.x,offset))) {
				[results addObject:index];
			}
		}
	}
	
	return results;
}

- (NSIndexPath *)indexPathForRowAtPoint:(CGPoint)point
{
	NSArray *paths = [self indexPathsForRowsInRect:CGRectMake(point.x,point.y,1,1)];
	return ([paths count] > 0)? [paths objectAtIndex:0] : nil;
}

- (NSArray *)indexPathsForVisibleRows
{
	NSMutableArray *indexes = [NSMutableArray arrayWithCapacity:[_activeCells count]];

	for (NSIndexPath *index in [_activeCells allKeys]) {
		UITableViewCell *cell = [_activeCells objectForKey:index];
		if (CGRectIntersectsRect(cell.frame,self.bounds)) {
			[indexes addObject:index];
		}
	}
	
	return indexes;
}

- (NSArray *)visibleCells
{
	NSMutableArray *cells = [[NSMutableArray new] autorelease];
	for (NSIndexPath *index in [self indexPathsForVisibleRows]) {
		UITableViewCell *cell = [self cellForRowAtIndexPath:index];
		if (cell) {
			[cells addObject:cell];
		}
	}
	return cells;
}

- (void)_layoutCells
{
	NSMutableDictionary *newActiveCells = [NSMutableDictionary dictionaryWithCapacity:[_activeCells count]];
	NSArray *indexesSortedByOffset = [_cellOffsets keysSortedByValueUsingSelector:@selector(compare:)];
	const CGFloat currentOffset = self.contentOffset.y;
	const CGFloat maxOffset = currentOffset + self.bounds.size.height;
	
	for (NSIndexPath *index in indexesSortedByOffset) {
		const CGFloat cellOffset = [[_cellOffsets objectForKey:index] floatValue];
		const CGFloat cellHeight = [[_cellHeights objectForKey:index] floatValue];

		if (cellOffset > maxOffset) {
			break;
		} else if ((cellOffset+cellHeight) >= currentOffset) {
			UITableViewCell *theCell = [_activeCells objectForKey:index];

			if (!theCell) {
				theCell = [self.dataSource tableView:self cellForRowAtIndexPath:index];
			} else {
				[_activeCells removeObjectForKey:index];
			}
			
			if (theCell && cellHeight > 0) {
				theCell.autoresizingMask = UIViewAutoresizingFlexibleWidth;
				theCell.frame = [self rectForRowAtIndexPath:index];
				[theCell _setSeparatorStyle:_separatorStyle color:_separatorColor];
				[self addSubview:theCell];
				[newActiveCells setObject:theCell forKey:index];
			}
		}
	}
	
	for (UITableViewCell *unusedCell in [_activeCells allValues]) {
		[unusedCell removeFromSuperview];
	}
	
	[_activeCells setDictionary:newActiveCells];
}

- (void)_recalculateCellOffsets
{
	[_cellOffsets removeAllObjects];
	
	CGFloat offset = 0;
	
	for (NSIndexPath *index in [[_cellHeights allKeys] sortedArrayUsingSelector:@selector(compare:)] ) {
		[_cellOffsets setObject:[NSNumber numberWithFloat:offset] forKey:index];

		offset += [[_cellHeights objectForKey:index] floatValue];

		if (_separatorStyle != UITableViewCellSeparatorStyleNone)
			offset += 1;
	}
	
	self.contentSize = CGSizeMake(0,offset);
}

- (NSInteger)numberOfSections
{
	if ([self.dataSource respondsToSelector:@selector(numberOfSectionsInTableView:)]) {
		return [self.dataSource numberOfSectionsInTableView:self];
	} else {
		return 1;
	}
}

- (NSInteger)numberOfRowsInSection:(NSInteger)section
{
	return [self.dataSource tableView:self numberOfRowsInSection:section];
}

- (void)reloadData
{
	[_cellHeights removeAllObjects];
	const BOOL delegateProvidesHeight = [self.delegate respondsToSelector:@selector(tableView:heightForRowAtIndexPath:)];
	const CGFloat defaultRowHeight = self.rowHeight ?: kDefaultRowHeight;
	
	const NSInteger numberOfSections = [self numberOfSections];
	for (NSInteger section=0; section<numberOfSections; section++) {
		const NSInteger numberOfRows = [self numberOfRowsInSection:section];
		for (NSInteger row=0; row<numberOfRows; row++) {
			NSIndexPath *rowIndexPath = [NSIndexPath indexPathForRow:row inSection:section];
			CGFloat theRowHeight = delegateProvidesHeight? [self.delegate tableView:self heightForRowAtIndexPath:rowIndexPath] : defaultRowHeight;
			[_cellHeights setObject:[NSNumber numberWithFloat:theRowHeight] forKey:rowIndexPath];
		}
	}
	
	[self _recalculateCellOffsets];
	[self _layoutCells];
	_needsReload = NO;
}

- (void)layoutSubviews
{
	if (_needsReload) {
		[self reloadData];
	} else {
		[self _layoutCells];
	}
	
	[super layoutSubviews];
}

- (NSIndexPath *)indexPathForSelectedRow
{
	return nil;
}

- (NSIndexPath *)indexPathForCell:(UITableViewCell *)cell
{
	return nil;
}

- (void)deselectRowAtIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated
{
}

- (void)selectRowAtIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated scrollPosition:(UITableViewScrollPosition)scrollPosition
{
}

- (void)scrollToNearestSelectedRowAtScrollPosition:(UITableViewScrollPosition)scrollPosition animated:(BOOL)animated
{
}

- (void)scrollToRowAtIndexPath:(NSIndexPath *)indexPath atScrollPosition:(UITableViewScrollPosition)scrollPosition animated:(BOOL)animated
{
}

- (UITableViewCell *)dequeueReusableCellWithIdentifier:(NSString *)identifier
{
	return nil;
}

@end
