//  Created by Sean Heber on 6/25/10.
#import <Foundation/Foundation.h>

@class UIBarButtonItem, UIView;

@interface UINavigationItem : NSObject {
@private
	NSString *_title;
	NSString *_prompt;
	UIBarButtonItem *_backBarButtonItem;
	UIBarButtonItem *_leftBarButtonItem;
	UIBarButtonItem *_rightBarButtonItem;
	UIView *_titleView;
	BOOL _hidesBackButton;
}

- (id)initWithTitle:(NSString *)title;
- (void)setLeftBarButtonItem:(UIBarButtonItem *)item animated:(BOOL)animated;
- (void)setRightBarButtonItem:(UIBarButtonItem *)item animated:(BOOL)animated;
- (void)setHidesBackButton:(BOOL)hidesBackButton animated:(BOOL)animated;

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *prompt;
@property (nonatomic, retain) UIBarButtonItem *backBarButtonItem;
@property (nonatomic, retain) UIBarButtonItem *leftBarButtonItem;
@property (nonatomic, retain) UIBarButtonItem *rightBarButtonItem;
@property (nonatomic, retain) UIView *titleView;
@property (nonatomic, assign) BOOL hidesBackButton;

@end
