//
//  SSSegmentedControl.h
//  SSToolkit
//
//  Created by Sam Soffes on 2/7/11.
//  Copyright 2011 Sam Soffes. All rights reserved.
//

// Limitiations:
// - Removing and inserting items is not supported
// - Setting item width is not supported
// - Setting item content offset is not supported

#import "UIControl.h"

@class UIImage;

typedef NS_ENUM(NSInteger, UISegmentedControlStyle) {
    UISegmentedControlStylePlain,     // large plain
    UISegmentedControlStyleBordered,  // large bordered
    UISegmentedControlStyleBar,       // small button/nav bar style. tintable
    UISegmentedControlStyleBezeled,   // large bezeled style. tintable
};

enum {
    UISegmentedControlNoSegment = -1   // segment index for no selected segment
};

typedef NS_ENUM(NSInteger, UISegmentedControlSegment) {
    UISegmentedControlSegmentAny = 0,
    UISegmentedControlSegmentLeft = 1,
    UISegmentedControlSegmentCenter = 2,
    UISegmentedControlSegmentRight = 3,
    UISegmentedControlSegmentAlone = 4,
};

@interface UISegmentedControl : UIControl
@property (nonatomic) UISegmentedControlStyle segmentedControlStyle; // stub
@property (nonatomic,strong) UIColor *tintColor; // stub
@property (nonatomic, assign, readonly) NSUInteger numberOfSegments;
@property (nonatomic, assign) NSInteger selectedSegmentIndex;
@property (nonatomic, getter=isMomentary) BOOL momentary;

- (id)initWithItems:(NSArray *)items;

- (void)setTitle:(NSString *)title forSegmentAtIndex:(NSUInteger)segment;
- (NSString *)titleForSegmentAtIndex:(NSUInteger)segment;

- (void)setImage:(UIImage *)image forSegmentAtIndex:(NSUInteger)segment;
- (UIImage *)imageForSegmentAtIndex:(NSUInteger)segment;

- (void)setEnabled:(BOOL)enabled forSegmentAtIndex:(NSUInteger)segment;
- (BOOL)isEnabledForSegmentAtIndex:(NSUInteger)segment;

- (void)setTitleTextAttributes:(NSDictionary *)attributes forState:(UIControlState)state;
- (NSDictionary *)titleTextAttributesForState:(UIControlState)state;
@end
