//
//  Player.h
//  NavBarUpdates
//
//  Created by John Pope on 15/01/2015.
//  Copyright (c) 2015 XPlatform Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KACircleProgressView.h"

@interface Player : UIView
{
    UISlider *slider0;
    UISlider *slider1;
    UILabel *lblProgress;
    UILabel *lblDuration;
    double duration;
    double currentValue;
    KACircleProgressView *circlePV;
}
@end
