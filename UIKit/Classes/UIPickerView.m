//
//  UIPickerView.m
//  UIKit
//
//  Created by Casey Marshall on 3/23/11.
//  Copyright 2011 Modal Domains. All rights reserved.
//

#import "UIPickerView.h"

@implementation UIPickerView

@synthesize delegate = _delegate;
@synthesize dataSource = _dataSource;
@synthesize showsSelectionIndicator = _showsSelectionIndicator;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (NSInteger) numberOfComponents
{
    // TODO
    return 0;
}

- (NSInteger) numberOfRowsInComponent:(NSInteger)component
{
    // TODO
    return 0;
}

- (CGSize) rowSizeForComponent:(NSInteger)component
{
    // TODO
    return CGSizeZero;
}

- (void) reloadAllComponents
{
    // TODO
}

- (void) reloadComponent:(NSInteger)component
{
    // TODO
}

- (void) selectRow:(NSInteger)row inComponent:(NSInteger)component animated:(BOOL)animated
{
    // TODO
}

- (NSInteger) selectedRowInComponent:(NSInteger)component
{
    // TODO
    return -1;
}

- (UIView *) viewForRow:(NSInteger)row forComponent:(NSInteger)component
{
    // TODO
    return nil;
}

- (void)dealloc
{
    [super dealloc];
}

@end
