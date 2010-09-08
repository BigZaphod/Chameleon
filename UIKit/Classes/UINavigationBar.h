//  Created by Sean Heber on 6/25/10.
#import "UIView.h"

@class UIColor, UINavigationItem, UINavigationBar;

@protocol UINavigationBarDelegate <NSObject>
@optional
- (BOOL)navigationBar:(UINavigationBar *)navigationBar shouldPushItem:(UINavigationItem *)item;
- (void)navigationBar:(UINavigationBar *)navigationBar didPushItem:(UINavigationItem *)item;
- (BOOL)navigationBar:(UINavigationBar *)navigationBar shouldPopItem:(UINavigationItem *)item;
- (void)navigationBar:(UINavigationBar *)navigationBar didPopItem:(UINavigationItem *)item;
@end

@interface UINavigationBar : UIView {
@private
	NSMutableArray *_navStack;
	UIColor *_tintColor;
	id _delegate;
	UIView *_leftView;
	UIView *_centerView;
	UIView *_rightView;
	
	struct {
		BOOL shouldPushItem : 1;
		BOOL didPushItem : 1;
		BOOL shouldPopItem : 1;
		BOOL didPopItem : 1;
	} _delegateHas;
}

- (void)setItems:(NSArray *)items animated:(BOOL)animated;
- (void)pushNavigationItem:(UINavigationItem *)item animated:(BOOL)animated;
- (UINavigationItem *)popNavigationItemAnimated:(BOOL)animated;

@property (nonatomic, retain) UIColor *tintColor;
@property (nonatomic, readonly, retain) UINavigationItem *topItem;
@property (nonatomic, readonly, retain) UINavigationItem *backItem;
@property (nonatomic, copy) NSArray *items;
@property (nonatomic, assign) id delegate;

@end
