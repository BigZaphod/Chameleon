//  Created by Sean Heber on 6/4/10.
#import "UITableView.h"
#import "UIScrollView+UIPrivate.h"
#import "UITableViewCell+UIPrivate.h"
#import "UIColor.h"
#import "UITouch.h"

static const CGFloat kDefaultRowHeight = 43;

@interface UITableView ()
- (void)_setNeedsReload;
@end

@implementation UITableView
@synthesize style=_style, dataSource=_dataSource, rowHeight=_rowHeight, separatorStyle=_separatorStyle, separatorColor=_separatorColor;
@synthesize tableHeaderView=_tableHeaderView, tableFooterView=_tableFooterView, allowsSelection=_allowsSelection, editing=_editing;
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
	[_selectedRow release];
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

- (CGRect)rectForSection:(NSInteger)section
{
	return CGRectZero;
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
	
	NSMutableArray *results = [[NSMutableArray new] autorelease];
	
	for (NSIndexPath *index in [_cellOffsets allKeys]) {
		CGRect cellRect = [self rectForRowAtIndexPath:index];
		if (CGRectIntersectsRect(rect,cellRect)) {
			[results addObject:index];
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
	const CGRect bounds = self.bounds;
	const CGFloat boundsWidth = bounds.size.width-_UIScrollViewScrollerSize-self.scrollIndicatorInsets.right;

	_tableHeaderView.frame = CGRectMake(0,0,boundsWidth,_tableHeaderView.frame.size.height);

	if ([_cellOffsets count] == 0) {
		_tableFooterView.frame = CGRectMake(0,_tableHeaderView.frame.size.height,boundsWidth,_tableFooterView.frame.size.height);
	} else {
		NSArray *indexesSortedByOffset = [_cellOffsets keysSortedByValueUsingSelector:@selector(compare:)];
		const CGFloat currentOffset = self.contentOffset.y;
		const CGFloat maxOffset = currentOffset + bounds.size.height;
		
		CGRect lastCellRect = [self rectForRowAtIndexPath:[indexesSortedByOffset lastObject]];
		_tableFooterView.frame = CGRectMake(0,lastCellRect.origin.y+lastCellRect.size.height,boundsWidth,_tableFooterView.frame.size.height);
		
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
					theCell.selected = [_selectedRow isEqual:index];
					theCell.autoresizingMask = UIViewAutoresizingFlexibleWidth;
					theCell.frame = [self rectForRowAtIndexPath:index];
					theCell.backgroundColor = self.backgroundColor;
					[theCell _setSeparatorStyle:_separatorStyle color:_separatorColor];
					[self addSubview:theCell];
					[newActiveCells setObject:theCell forKey:index];
				}
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
	
	CGFloat offset = _tableHeaderView.frame.size.height;
	
	for (NSIndexPath *index in [[_cellHeights allKeys] sortedArrayUsingSelector:@selector(compare:)] ) {
		[_cellOffsets setObject:[NSNumber numberWithFloat:offset] forKey:index];

		offset += [[_cellHeights objectForKey:index] floatValue];

		if (_separatorStyle != UITableViewCellSeparatorStyleNone)
			offset += 1;
	}
	
	offset += _tableFooterView.frame.size.height;
	
	self.contentSize = CGSizeMake(0,offset);

	[self setNeedsLayout];
}

- (void)setTableHeaderView:(UIView *)newHeader
{
	if (newHeader != _tableHeaderView) {
		[_tableHeaderView removeFromSuperview];
		[_tableHeaderView release];
		_tableHeaderView = [newHeader retain];
		[self _recalculateCellOffsets];
		[self addSubview:_tableHeaderView];
	}
}

- (void)setTableFooterView:(UIView *)newFooter
{
	if (newFooter != _tableFooterView) {
		[_tableFooterView removeFromSuperview];
		[_tableFooterView release];
		_tableFooterView = [newFooter retain];
		[self _recalculateCellOffsets];
		[self addSubview:_tableFooterView];
	}
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
	_selectedRow = nil;
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
	_needsReload = NO;
}

- (void)layoutSubviews
{
	if (_needsReload) {
		[self reloadData];
	}
	[self _layoutCells];
	[super layoutSubviews];
}

- (NSIndexPath *)indexPathForSelectedRow
{
	return _selectedRow;
}

- (NSIndexPath *)indexPathForCell:(UITableViewCell *)cell
{
	for (NSIndexPath *index in [_activeCells allKeys]) {
		if ([_activeCells objectForKey:index] == cell) {
			return index;
		}
	}
	
	return nil;
}

- (void)deselectRowAtIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated
{
	if (indexPath == _selectedRow) {
		[self cellForRowAtIndexPath:_selectedRow].selected = NO;
		[_selectedRow release];
		_selectedRow = nil;
	}
}

- (void)selectRowAtIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated scrollPosition:(UITableViewScrollPosition)scrollPosition
{
	if (_selectedRow != indexPath) {
		[_selectedRow release];
		_selectedRow = [indexPath retain];
		[self cellForRowAtIndexPath:_selectedRow].selected = YES;
	}
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

- (void)setEditing:(BOOL)editing animated:(BOOL)animate
{
	_editing = editing;
}

- (void)setEditing:(BOOL)editing
{
	[self setEditing:editing animated:NO];
}

- (void)insertRowsAtIndexPaths:(NSArray *)indexPaths withRowAnimation:(UITableViewRowAnimation)animation
{
}

- (void)deleteRowsAtIndexPaths:(NSArray *)indexPaths withRowAnimation:(UITableViewRowAnimation)animation
{
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
	UITouch *touch = [touches anyObject];
	CGPoint location = [touch locationInView:self];
	NSIndexPath *touchedRow = [self indexPathForRowAtPoint:location];
	
	if (touchedRow) {
		NSIndexPath *selectedRow = [self indexPathForSelectedRow];

		if (selectedRow) {
			NSIndexPath *rowToDeselect = selectedRow;
			
			if ([_delegate respondsToSelector:@selector(tableView:willDeselectRowAtIndexPath:)]) {
				rowToDeselect = [_delegate tableView:self willDeselectRowAtIndexPath:rowToDeselect];
			}
			
			[self deselectRowAtIndexPath:rowToDeselect animated:NO];
			
			if ([_delegate respondsToSelector:@selector(tableView:didDeselectRowAtIndexPath:)]) {
				[_delegate tableView:self didDeselectRowAtIndexPath:rowToDeselect];
			}
		}

		NSIndexPath *rowToSelect = touchedRow;
		
		if ([_delegate respondsToSelector:@selector(tableView:willSelectRowAtIndexPath:)]) {
			rowToSelect = [_delegate tableView:self willSelectRowAtIndexPath:rowToSelect];
		}

		[self selectRowAtIndexPath:rowToSelect animated:NO scrollPosition:UITableViewScrollPositionNone];
		
		if ([_delegate respondsToSelector:@selector(tableView:didSelectRowAtIndexPath:)]) {
			[_delegate tableView:self didSelectRowAtIndexPath:rowToSelect];
		}
	}
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
}

@end
