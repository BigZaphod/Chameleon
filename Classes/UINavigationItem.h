//  Created by Sean Heber on 6/25/10.
#import <Foundation/Foundation.h>

@class UIBarButtonItem, UIView;

@interface UINavigationItem : NSObject {
@private
	NSString *_title;
	UIBarButtonItem *_rightBarButtonItem;
	UIView *_titleView;
}

- (id)initWithTitle:(NSString *)title;
- (void)setLeftBarButtonItem:(UIBarButtonItem *)item animated:(BOOL)animated;
- (void)setRightBarButtonItem:(UIBarButtonItem *)item animated:(BOOL)animated;

@property (nonatomic, copy) NSString *title;
@property (nonatomic, retain) UIBarButtonItem *rightBarButtonItem;
@property (nonatomic, retain) UIView *titleView;

@end
