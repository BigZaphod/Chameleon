//
//  UIPickerView.h
//  UIKit
//
//  Created by Casey Marshall on 3/23/11.
//  Copyright 2011 Modal Domains. All rights reserved.
//

#import <UIKit/UIKit.h>

@class UIPickerView;
@protocol UIPickerViewDelegate <NSObject>

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component;
- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component;

@end

@protocol UIPickerViewDataSource <NSObject>

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView;
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component;

@end

@interface UIPickerView : UIView
{
@protected
    id<UIPickerViewDelegate> *_delegate;
    id<UIPickerViewDataSource> *_dataSource;
    BOOL _showsSelectionIndicator;
}

@property (nonatomic, assign) id<UIPickerViewDelegate> *delegate;
@property (nonatomic, assign) id<UIPickerViewDataSource> *dataSource;

@property (nonatomic, assign) BOOL showsSelectionIndicator;
@property (nonatomic, readonly) NSInteger numberOfComponents;

- (NSInteger) numberOfRowsInComponent: (NSInteger) component;
- (CGSize) rowSizeForComponent: (NSInteger) component;

- (void) reloadAllComponents;
- (void) reloadComponent: (NSInteger) component;

- (void)selectRow:(NSInteger)row inComponent:(NSInteger)component animated:(BOOL)animated;
- (NSInteger) selectedRowInComponent: (NSInteger) component;

- (UIView *)viewForRow:(NSInteger)row forComponent:(NSInteger)component;

@end
