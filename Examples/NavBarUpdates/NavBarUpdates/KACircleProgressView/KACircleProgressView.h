//
//  KACircleProgressView.h
//  KACircleProgressView
//
//  Created by Kenneth Parker Ackerson on 11/20/13.
//  Copyright (c) 2013 Kenneth Parker Ackerson. All rights reserved.
//
typedef enum{
    KACircleProgressViewTypeCirclePlain, // no circle behind the progress
    KACircleProgressViewTypeCircleBacked, // circle behind the progress
} KACircleProgressViewType; // type
#import <UIKit/UIKit.h>

@interface KACircleProgressView : UIView{

}

@property (nonatomic, assign) float progress; // progress of the progress view

@property (nonatomic, assign) KACircleProgressViewType type; // type of progress view

@property (nonatomic, strong) UIButton * button;


// initializer that takes a size (width AND height of view) and a type of progress view
- (id)initWithSize:(float)size withType:(KACircleProgressViewType)type;

// also allows you to set the progress bar line width
- (id)initWithSize:(float)size withType:(KACircleProgressViewType)type andProgressBarLineWidth:(int)progressBarLineWidth;

// also allows you to set the progress bar line width AND the line width of the backround circle (if its type KACircleProgressViewTypeCircleBacked)
- (id)initWithSize:(float)size withType:(KACircleProgressViewType)type andProgressBarLineWidth:(int)progressBarLineWidth andCircleBackLineWidth:(int)circlebackLW;

// sets color of the progress bar
- (void)setColorOfProgressBar:(UIColor *)color;

// sets color of background circle in KACircleProgressViewTypeCircleBacked
- (void)setColorOfBackCircle:(UIColor *)color;
@end
