//
//  UINSCellControl.h
//  UIKit
//
//  Created by Jim Dovey on 11-03-23.
//  Copyright 2011 XPlatform Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UIControl.h"

@class NSCell, UIImage, UIFont;

@interface UINSCellControl : UIControl {
@private
    NSCell *		_cell;
}

+ (UINSCellControl *)checkboxWithFrame:(CGRect)frame;

- (id)initWithFrame:(CGRect)frame cell:(NSCell *)cell;

@property (nonatomic, readonly) NSCell * cell;

@property (nonatomic, copy) NSString * title;
@property (nonatomic, copy) UIImage * image;
@property (nonatomic, copy) UIFont * font;

@end
