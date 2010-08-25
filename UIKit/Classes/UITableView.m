//  Created by Sean Heber on 6/4/10.
#import "UITableView.h"
#import "UIScrollView+UIPrivate.h"
#import "UITableViewCell+UIPrivate.h"
#import "UIColor.h"
#import "UITouch.h"
#import "UITableViewSection.h"
#import "UITableViewSectionLabel.h"

const CGFloat _UITableViewDefaultRowHeight = 43;

@interface UITableView ()
- (void)_setNeedsReload;
@end

@implementation UITableView
@synthesize style=_style, dataSource=_dataSource, rowHeight=_rowHeight, separatorStyle=_separatorStyle, separatorColor=_separatorColor;
@synthesize tableHeaderView=_tableHeaderView, tableFooterView=_tableFooterView, allowsSelection=_allowsSelection, editing=_editing;
@synthesize sectionFooterHeight=_sectionFooterHeight, sectionHeaderHeight=_sectionHeaderHeight;
@dynamic delegate;

- (id)initWithFrame:(CGRect)frame
{
	return [self initWithFrame:frame style:UITableViewStylePlain];
}

- (id)initWithFrame:(CGRect)frame style:(UITableViewStyle)theStyle
{
	if ((self=[super initWithFrame:frame])) {
		_style = theStyle;
		_cachedCells = [NSMutableDictionary new];
		_sections = [NSMutableArray new];

		self.separatorColor = [UIColor colorWithRed:.88f green:.88f blue:.88f alpha:1];
		self.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
		self.showsHorizontalScrollIndicator = NO;
		self.allowsSelection = YES;
		self.sectionHeaderHeight = self.sectionFooterHeight = 22;

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
	[_tableFooterView release];
	[_tableHeaderView release];
	[_cachedCells release];
	[_sections release];
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

- (CGRect)_CGRectFromVerticalOffset:(CGFloat)offset height:(CGFloat)height
{
	const CGFloat scrollerAdjustment = [self _canScrollVertical]? (_UIScrollViewScrollerSize-self.scrollIndicatorInsets.right) : 0;
	const CGFloat width = self.bounds.size.width - scrollerAdjustment;
	return CGRectMake(0,offset,width,height);
}

- (CGFloat)_offsetForSection:(NSInteger)section
{
	CGFloat offset = _tableHeaderView? _tableHeaderView.frame.size.height : 0;
	
	for (NSInteger s=0; s<section; s++) {
		offset += [[_sections objectAtIndex:s] sectionHeight];
	}
	
	return offset;
}

- (CGRect)rectForSection:(NSInteger)section
{
	return [self _CGRectFromVerticalOffset:[self _offsetForSection:section] height:[[_sections objectAtIndex:section] sectionHeight]];
}

- (CGRect)rectForHeaderInSection:(NSInteger)section
{
	return [self _CGRectFromVerticalOffset:[self _offsetForSection:section] height:[[_sections objectAtIndex:section] headerHeight]];
}

- (CGRect)rectForFooterInSection:(NSInteger)section
{
	UITableViewSection *sectionRecord = [_sections objectAtIndex:section];
	CGFloat offset = [self _offsetForSection:section];
	offset += sectionRecord.headerHeight;
	offset += sectionRecord.rowsHeight;
	return [self _CGRectFromVerticalOffset:offset height:sectionRecord.footerHeight];
}

- (CGRect)rectForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewSection *sectionRecord = [_sections objectAtIndex:indexPath.section];
	CGFloat offset = [self _offsetForSection:indexPath.section];
	offset += sectionRecord.headerHeight;
	
	for (NSInteger row=0; row<indexPath.row; row++) {
		offset += [[sectionRecord.rowHeights objectAtIndex:row] floatValue];
	}
	
	return [self _CGRectFromVerticalOffset:offset height:[[sectionRecord.rowHeights objectAtIndex:indexPath.row] floatValue]];
}

- (UITableViewCell *)cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	// this is allowed to return nil if the cell isn't visible and is not restricted to only returning visible cells
	// so this simple call should be good enough.
	return [_cachedCells objectForKey:indexPath];
}

- (NSArray *)indexPathsForRowsInRect:(CGRect)rect
{
	// This needs to return the index paths even if the cells don't exist in any caches or are not on screen
	// For now I'm assuming the cells stretch all the way across the view. It's not clear to me if the real
	// implementation gets anal about this or not (haven't tested it).

	NSMutableArray *results = [NSMutableArray new];
	const NSInteger numberOfSections = [_sections count];
	CGFloat offset = _tableHeaderView? _tableHeaderView.frame.size.height : 0;
	
	for (NSInteger section=0; section<numberOfSections; section++) {
		UITableViewSection *sectionRecord = [_sections objectAtIndex:section];
		const NSInteger numberOfRows = sectionRecord.numberOfRows;
		
		offset += sectionRecord.headerHeight;

		if (offset + sectionRecord.rowsHeight >= rect.origin.y) {
			for (NSInteger row=0; row<numberOfRows; row++) {
				const CGFloat height = [[sectionRecord.rowHeights objectAtIndex:row] floatValue];
				CGRect simpleRowRect = CGRectMake(rect.origin.x, offset, rect.size.width, height);
				
				if (CGRectIntersectsRect(rect,simpleRowRect)) {
					[results addObject:[NSIndexPath indexPathForRow:row inSection:section]];
				} else if (simpleRowRect.origin.y > rect.origin.y+rect.size.height) {
					break;	// don't need to find anything else.. we are past the end
				}
				
				offset += height;
			}
		} else {
			offset += sectionRecord.rowsHeight;
		}
		
		offset += sectionRecord.footerHeight;
	}
	
	return [results autorelease];
}

- (NSIndexPath *)indexPathForRowAtPoint:(CGPoint)point
{
	NSArray *paths = [self indexPathsForRowsInRect:CGRectMake(point.x,point.y,1,1)];
	return ([paths count] > 0)? [paths objectAtIndex:0] : nil;
}

- (NSArray *)indexPathsForVisibleRows
{
	NSMutableArray *indexes = [NSMutableArray arrayWithCapacity:[_cachedCells count]];
	const CGRect bounds = self.bounds;

	for (NSIndexPath *indexPath in [_cachedCells allKeys]) {
		if (CGRectIntersectsRect(bounds,[self rectForRowAtIndexPath:indexPath])) {
			[indexes addObject:indexPath];
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

- (void)_updateContentSize
{
	CGFloat height = _tableHeaderView? _tableHeaderView.frame.size.height : 0;
	
	for (UITableViewSection *section in _sections) {
		height += [section sectionHeight];
	}
	
	if (_tableFooterView) {
		height += _tableFooterView.frame.size.height;
	}
	
	self.contentSize = CGSizeMake(0,height);
}

- (void)setTableHeaderView:(UIView *)newHeader
{
	if (newHeader != _tableHeaderView) {
		[_tableHeaderView removeFromSuperview];
		[_tableHeaderView release];
		_tableHeaderView = [newHeader retain];
		[self _updateContentSize];
		[self addSubview:_tableHeaderView];
	}
}

- (void)setTableFooterView:(UIView *)newFooter
{
	if (newFooter != _tableFooterView) {
		[_tableFooterView removeFromSuperview];
		[_tableFooterView release];
		_tableFooterView = [newFooter retain];
		[self _updateContentSize];
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
	const BOOL delegateProvidesRowHeight = [self.delegate respondsToSelector:@selector(tableView:heightForRowAtIndexPath:)];
	const BOOL delegateProvidesSectionHeaderHeight = [self.delegate respondsToSelector:@selector(tableView:heightForHeaderInSection:)];
	const BOOL delegateProvidesSectionFooterHeight = [self.delegate respondsToSelector:@selector(tableView:heightForFooterInSection:)];
	const BOOL delegateProvidesSectionHeaderView = [self.delegate respondsToSelector:@selector(tableView:viewForHeaderInSection:)];
	const BOOL delegateProvidesSectionFooterView = [self.delegate respondsToSelector:@selector(tableView:viewForFooterInSection:)];
	const BOOL datasourceProvidesSectionHeaderTitle = [self.dataSource respondsToSelector:@selector(tableView:titleForHeaderInSection:)];
	const BOOL datasourceProvidesSectionFooterTitle = [self.dataSource respondsToSelector:@selector(tableView:titleForFooterInSection:)];
	const CGFloat defaultRowHeight = _rowHeight ?: _UITableViewDefaultRowHeight;

	// clear prior selection
	[_selectedRow release];
	_selectedRow = nil;
	
	// empty out previously cached stuff
	[_sections removeAllObjects];
	[_cachedCells removeAllObjects];
	
	// compute the heights/offsets of everything
	const NSInteger numberOfSections = [self numberOfSections];
	for (NSInteger section=0; section<numberOfSections; section++) {
		const NSInteger numberOfRowsInSection = [self numberOfRowsInSection:section];
		
		UITableViewSection *sectionRecord = [UITableViewSection new];
		sectionRecord.numberOfRows = numberOfRowsInSection;
		sectionRecord.headerView = delegateProvidesSectionHeaderView? [self.delegate tableView:self viewForHeaderInSection:section] : nil;
		sectionRecord.footerView = delegateProvidesSectionFooterView? [self.delegate tableView:self viewForFooterInSection:section] : nil;
		sectionRecord.headerTitle = datasourceProvidesSectionHeaderTitle? [self.dataSource tableView:self titleForHeaderInSection:section] : nil;
		sectionRecord.footerTitle = datasourceProvidesSectionFooterTitle? [self.dataSource tableView:self titleForFooterInSection:section] : nil;
		
		// make a default section header view if there's a title for it and no overriding view
		if (!sectionRecord.headerView && sectionRecord.headerTitle) {
			sectionRecord.headerView = [UITableViewSectionLabel sectionLabelWithTitle:sectionRecord.headerTitle];
		}

		// make a default section footer view if there's a title for it and no overriding view
		if (!sectionRecord.footerView && sectionRecord.footerTitle) {
			sectionRecord.footerView = [UITableViewSectionLabel sectionLabelWithTitle:sectionRecord.footerTitle];
		}
		
		// if there's a view, then we need to set the height, otherwise it's going to be zero
		if (sectionRecord.headerView) {
			[self addSubview:sectionRecord.headerView];
			sectionRecord.headerHeight = delegateProvidesSectionHeaderHeight? [self.delegate tableView:self heightForHeaderInSection:section] : _sectionHeaderHeight;
		} else {
			sectionRecord.headerHeight = 0;
		}

		if (sectionRecord.footerView) {
			[self addSubview:sectionRecord.footerView];
			sectionRecord.footerHeight = delegateProvidesSectionFooterHeight? [self.delegate tableView:self heightForFooterInSection:section] : _sectionFooterHeight;
		} else {
			sectionRecord.footerHeight = 0;
		}

		NSMutableArray *rowHeights = [[NSMutableArray alloc] initWithCapacity:numberOfRowsInSection];
		CGFloat totalRowsHeight = 0;
		
		for (NSInteger row=0; row<numberOfRowsInSection; row++) {
			const CGFloat rowHeight = delegateProvidesRowHeight? [self.delegate tableView:self heightForRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:section]] : defaultRowHeight;
			[rowHeights addObject:[NSNumber numberWithFloat:rowHeight]];
			totalRowsHeight += rowHeight;
		}
		
		sectionRecord.rowsHeight = totalRowsHeight;
		sectionRecord.rowHeights = rowHeights;
		
		[_sections addObject:sectionRecord];
		[sectionRecord release];
		[rowHeights release];
	}
	
	_needsReload = NO;
	[self _updateContentSize];
	[self setNeedsLayout];
}

- (void)layoutSubviews
{
	[super layoutSubviews];

	if (_needsReload) {
		[self reloadData];
	}
	
	// DO FANCY-PANTS STUFF HERE!
	const CGSize boundsSize = self.bounds.size;
	const CGFloat contentOffset = self.contentOffset.y;
	const CGRect visibleBounds = CGRectMake(0,contentOffset,boundsSize.width,boundsSize.height);
	CGFloat tableHeight = 0;
		
	if (_tableHeaderView) {
		CGRect tableHeaderFrame = _tableHeaderView.frame;
		tableHeaderFrame.origin = CGPointZero;
		tableHeaderFrame.size.width = boundsSize.width;
		_tableHeaderView.frame = tableHeaderFrame;
		_tableHeaderView.hidden = !CGRectIntersectsRect(tableHeaderFrame, visibleBounds);
		tableHeight += tableHeaderFrame.size.height;
	}
	
	// layout sections and rows
	NSMutableDictionary *availableCells = [_cachedCells mutableCopy];
	const NSInteger numberOfSections = [_sections count];
	[_cachedCells removeAllObjects];

	for (NSInteger section=0; section<numberOfSections; section++) {
		NSAutoreleasePool *sectionPool = [NSAutoreleasePool new];
		CGRect sectionRect = [self rectForSection:section];
		tableHeight += sectionRect.size.height;
		if (CGRectIntersectsRect(sectionRect, visibleBounds)) {
			const CGRect headerRect = [self rectForHeaderInSection:section];
			const CGRect footerRect = [self rectForFooterInSection:section];
			UITableViewSection *sectionRecord = [_sections objectAtIndex:section];
			const NSInteger numberOfRows = sectionRecord.numberOfRows;

			if (sectionRecord.headerView) {
				if (CGRectIntersectsRect(headerRect,visibleBounds)) {
					sectionRecord.headerView.frame = headerRect;
					sectionRecord.headerView.hidden = NO;
				} else {
					sectionRecord.headerView.hidden = YES;
				}
			}
			
			if (sectionRecord.footerView) {
				if (CGRectIntersectsRect(footerRect,visibleBounds)) {
					sectionRecord.footerView.frame = footerRect;
					sectionRecord.footerView.hidden = NO;
				} else {
					sectionRecord.footerView.hidden = YES;
				}
			}

			for (NSInteger row=0; row<numberOfRows; row++) {
				NSAutoreleasePool *rowPool = [NSAutoreleasePool new];
				NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:section];
				CGRect rowRect = [self rectForRowAtIndexPath:indexPath];
				if (CGRectIntersectsRect(rowRect,visibleBounds) && rowRect.size.height > 0) {
					UITableViewCell *cell = [availableCells objectForKey:indexPath] ?: [self.dataSource tableView:self cellForRowAtIndexPath:indexPath];
					if (cell) {
						[_cachedCells setObject:cell forKey:indexPath];
						[availableCells removeObjectForKey:indexPath];
						cell.selected = [_selectedRow isEqual:indexPath];
						cell.frame = rowRect;
						cell.backgroundColor = self.backgroundColor;
						[cell _setSeparatorStyle:_separatorStyle color:_separatorColor];
						[self addSubview:cell];
					}
				}
				[rowPool release];
			}
		}
		[sectionPool release];
	}
	
	// remove old cells
	for (UITableViewCell *cell in [availableCells allValues]) {
		[cell removeFromSuperview];
	}

	[availableCells release];
	
	if (_tableHeaderView) {
		CGRect tableFooterFrame = _tableFooterView.frame;
		tableFooterFrame.origin = CGPointMake(0,tableHeight);
		tableFooterFrame.size.width = boundsSize.width;
		_tableFooterView.frame = tableFooterFrame;
		_tableFooterView.hidden = !CGRectIntersectsRect(tableFooterFrame, visibleBounds);
	}
}

- (NSIndexPath *)indexPathForSelectedRow
{
	return _selectedRow;
}

- (NSIndexPath *)indexPathForCell:(UITableViewCell *)cell
{
	for (NSIndexPath *index in [_cachedCells allKeys]) {
		if ([_cachedCells objectForKey:index] == cell) {
			return index;
		}
	}
	
	return nil;
}

- (void)deselectRowAtIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated
{
	if ([indexPath isEqual:_selectedRow]) {
		[self cellForRowAtIndexPath:_selectedRow].selected = NO;
		[_selectedRow release];
		_selectedRow = nil;
	}
}

- (void)selectRowAtIndexPath:(NSIndexPath *)indexPath animated:(BOOL)animated scrollPosition:(UITableViewScrollPosition)scrollPosition
{
	if (![_selectedRow isEqual:indexPath]) {
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

@end
