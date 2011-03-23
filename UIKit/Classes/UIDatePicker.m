//
//  UIDatePicker.m
//  UIKit
//
//  Created by Casey Marshall on 3/23/11.
//  Copyright 2011 Modal Domains. All rights reserved.
//

#import "UIDatePicker.h"


@implementation UIDatePicker

@synthesize calendar = _calendar;
@synthesize date = _date;
@synthesize locale = _locale;
@synthesize timeZone = _timeZone;
@synthesize datePickerMode = _datePickerMode;
@synthesize minimumDate = _minimumDate;
@synthesize maximumDate = _maximumDate;
@synthesize minuteInterval = _minuteInterval;
@synthesize countDownDuration = _countDownDuration;

- (void) dealloc
{
    [_calendar release];
    [_date release];
    [_locale release];
    [_timeZone release];
    [_minimumDate release];
    [_maximumDate release];
    [super dealloc];
}

@end
