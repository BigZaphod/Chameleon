//
//  KACircleProgressView.m
//  KACircleProgressView
//
//  Created by Kenneth Parker Ackerson on 11/20/13.
//  Copyright (c) 2013 Kenneth Parker Ackerson. All rights reserved.
//

#import "KACircleProgressView.h"
@interface KACircleProgressView (){
    int lineWidthOfProgressBar;
    int lineWidthOfCircleBacking;
}
@property (nonatomic, strong) CAShapeLayer * progressBar; // progressbar shape
@property (nonatomic, strong) CAShapeLayer * backgroundCircle; // background circle shape


@end
@implementation KACircleProgressView
#pragma mark - Init Methods -

- (id)initWithSize:(float)size withType:(KACircleProgressViewType)type
{
    self = [super initWithFrame:CGRectMake(0, 0, size, size)];
    if (self) {
        lineWidthOfProgressBar = 8; // default value
        lineWidthOfCircleBacking = 6; // default value
        [self createLayersWithType:type];
    }
    return self;
}
- (id)initWithSize:(float)size withType:(KACircleProgressViewType)type andProgressBarLineWidth:(int)progressBarLineWidth
{
    self = [super initWithFrame:CGRectMake(0, 0, size, size)];
    if (self) {
        NSAssert(type == KACircleProgressViewTypeCirclePlain, @"Should not use this initializer with KACircleProgressViewTypeCirclePlain, please use - (id)initWithSize:(float)size withType:(KACircleProgressViewType)type andProgressBarLineWidth:(int)progressBarLineWidth andCircleBackLineWidth:(int)circlebackLW ");
        lineWidthOfProgressBar = progressBarLineWidth;
        lineWidthOfCircleBacking = 0; // default value, if you want to set this use "- (id)initWithSize:(float)size withType:(KACircleProgressViewType)type andProgressBarLineWidth:(int)progressBarLineWidth andCircleBackLineWidth:(int)circlebackLW"
        
        [self createLayersWithType:type];
    }
    return self;
}
- (id)initWithSize:(float)size withType:(KACircleProgressViewType)type andProgressBarLineWidth:(int)progressBarLineWidth andCircleBackLineWidth:(int)circlebackLW
{
    self = [super initWithFrame:CGRectMake(0, 0, size, size)];
    if (self) {
        NSAssert(type == KACircleProgressViewTypeCircleBacked, @"Should not use this initializer with KACircleProgressViewTypeCirclePlain, please use either of the other methods. ");
        lineWidthOfProgressBar = progressBarLineWidth;
        lineWidthOfCircleBacking = circlebackLW;
        [self createLayersWithType:type];
    }
    return self;
}
#pragma mark - General Methods -

// Just creating the progress view from any init
- (void)createLayersWithType:(KACircleProgressViewType)type{
    self.type = type;
    if (self.type == KACircleProgressViewTypeCircleBacked){
  
        self.button = [UIButton buttonWithType:UIButtonTypeCustom];
        //[self.button addTarget:self action:nil forControlEvents:UIControlEventTouchUpInside];
      //  [self.button setTitle:@"Tap to refresh" forState:UIControlStateNormal];
        self.button.titleLabel.font = [UIFont systemFontOfSize:12];
        
        self.button.frame = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.width);
        self.button.clipsToBounds = YES;
        self.button.layer.backgroundColor = [UIColor darkGrayColor].CGColor;
        self.button.layer.cornerRadius = self.bounds.size.width/2;//half of the width
        self.button.layer.borderColor=[UIColor redColor].CGColor;
        self.button.layer.borderWidth=lineWidthOfCircleBacking;
        
        [self addSubview:self.button];
        
    }    
    self.progressBar = [CAShapeLayer layer];
    self.progressBar.lineWidth = lineWidthOfProgressBar;
    self.progressBar.lineCap = kCALineCapSquare;
    self.progressBar.strokeColor = [UIColor cyanColor].CGColor;
    self.progressBar.fillColor = [UIColor clearColor].CGColor;
    [self.layer addSublayer:self.progressBar];
    
    [self setBackgroundColor:[UIColor clearColor]];
}


// setting color of progress bar
- (void)setColorOfProgressBar:(UIColor *)color{
    [self.progressBar setStrokeColor:color.CGColor];
    [self setNeedsDisplay];
}

// This method maintains square frame (width x width)
- (void)setFrame:(CGRect)frame{
    frame = CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, frame.size.width);
    self.button.frame = CGRectMake(0, 0, frame.size.width, frame.size.width);
    self.button.layer.cornerRadius = frame.size.width/2;
    [super setFrame:frame];
}
- (void)setProgress:(float)progress{
    if (progress > 1.0){
        progress = 1.0;
    }else if (progress < 0){
        progress = 0;
    }
    _progress = progress;
    [self setNeedsDisplay];
}
#pragma mark - Drawing Methods -

- (void)drawRect:(CGRect)rect
{
    CGFloat start = -(M_PI / 2.f);
    CGFloat end = (2.0 * self.progress * (float)M_PI) + start;
    CGFloat radius = (self.bounds.size.width - (lineWidthOfCircleBacking+lineWidthOfProgressBar)/2.f)/2.f; // center it inside other one - if it exists
    UIBezierPath *processBackgroundPath = [UIBezierPath bezierPath];
    processBackgroundPath.lineWidth = lineWidthOfProgressBar;
    [processBackgroundPath addArcWithCenter: CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2) radius:radius startAngle:start endAngle:end clockwise:YES];
    self.progressBar.path = processBackgroundPath.CGPath;
}
#pragma mark - Dealloc Method -

- (void)dealloc{
    self.backgroundCircle = nil;
    self.progressBar = nil;
}

@end
