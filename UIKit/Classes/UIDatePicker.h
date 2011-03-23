//
//  UIDatePicker.h
//  UIKit
//
//  Created by Casey Marshall on 3/23/11.
//  Copyright 2011 Modal Domains. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UIControl.h"

typedef enum {
    UIDatePickerModeTime,
    UIDatePickerModeDate,
    UIDatePickerModeDateAndTime,
    UIDatePickerModeCountDownTimer
} UIDatePickerMode;

@interface UIDatePicker : UIControl
{
    @private
    NSCalendar *_calendar;
    NSDate *_date;
    NSLocale *_locale;
    NSTimeZone *_timeZone;
    
    UIDatePickerMode _datePickerMode;
    
    NSDate *_minimumDate;
    NSDate *_maximumDate;
    NSInteger _minuteInterval;
    NSTimeInterval _countDownDuration;
}

@property (nonatomic, retain) NSCalendar *calendar;
@property (nonatomic, retain) NSDate *date;
@property (nonatomic, retain) NSLocale *locale;
@property (nonatomic, retain) NSTimeZone *timeZone;

@property (nonatomic, assign) UIDatePickerMode datePickerMode;

@property (nonatomic, retain) NSDate *minimumDate;
@property (nonatomic, retain) NSDate *maximumDate;
@property (nonatomic, assign) NSInteger minuteInterval;
@property (nonatomic, assign) NSTimeInterval countDownDuration;

@end
