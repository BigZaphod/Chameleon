//  Created by Sean Heber on 8/19/10.
#import <Foundation/Foundation.h>

@class UIView;

@interface UITableViewSection : NSObject {
	CGFloat rowsHeight;
	CGFloat headerHeight;
	CGFloat footerHeight;
	NSInteger numberOfRows;
	NSArray *rowHeights;
	UIView *headerView;
	UIView *footerView;
	NSString *headerTitle;
	NSString *footerTitle;
}

- (CGFloat)sectionHeight;
@property (nonatomic, assign) CGFloat rowsHeight;
@property (nonatomic, assign) CGFloat headerHeight;
@property (nonatomic, assign) CGFloat footerHeight;
@property (nonatomic, assign) NSInteger numberOfRows;
@property (nonatomic, copy) NSArray *rowHeights;
@property (nonatomic, retain) UIView *headerView;
@property (nonatomic, retain) UIView *footerView;
@property (nonatomic, copy) NSString *headerTitle;
@property (nonatomic, copy) NSString *footerTitle;

@end

