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
#import "UIImage.h"
#import "UIFont.h"

typedef enum {
  UISegmentedControlStylePlain,     // large plain
  UISegmentedControlStyleBordered,  // large bordered
  UISegmentedControlStyleBar,       // small button/nav bar style. tintable
  UISegmentedControlStyleBezeled,   // large bezeled style. tintable
} UISegmentedControlStyle;

enum {
  UISegmentedControlNoSegment = -1   // segment index for no selected segment
};

@interface UISegmentedControl : UIControl 

@property (nonatomic) UISegmentedControlStyle segmentedControlStyle; // stub
@property (nonatomic,retain) UIColor *tintColor; // stub
@property (nonatomic, assign, readonly) NSUInteger numberOfSegments;
@property (nonatomic, assign) NSInteger selectedSegmentIndex;
@property (nonatomic, getter=isMomentary) BOOL momentary;

- (id)initWithItems:(NSArray *)items;

//- (void)insertSegmentWithTitle:(NSString *)title atIndex:(NSUInteger)segment animated:(BOOL)animated;
//- (void)insertSegmentWithImage:(UIImage *)image  atIndex:(NSUInteger)segment animated:(BOOL)animated;
//- (void)removeSegmentAtIndex:(NSUInteger)segment animated:(BOOL)animated;
//- (void)removeAllSegments;

- (void)setTitle:(NSString *)title forSegmentAtIndex:(NSUInteger)segment;
- (NSString *)titleForSegmentAtIndex:(NSUInteger)segment;

- (void)setImage:(UIImage *)image forSegmentAtIndex:(NSUInteger)segment;
- (UIImage *)imageForSegmentAtIndex:(NSUInteger)segment;

//- (void)setWidth:(CGFloat)width forSegmentAtIndex:(NSUInteger)segment;
//- (CGFloat)widthForSegmentAtIndex:(NSUInteger)segment;

//- (void)setContentOffset:(CGSize)offset forSegmentAtIndex:(NSUInteger)segment;
//- (CGSize)contentOffsetForSegmentAtIndex:(NSUInteger)segment;

- (void)setEnabled:(BOOL)enabled forSegmentAtIndex:(NSUInteger)segment;
- (BOOL)isEnabledForSegmentAtIndex:(NSUInteger)segment;

@end
