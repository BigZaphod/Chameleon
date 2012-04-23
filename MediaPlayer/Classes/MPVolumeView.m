//
//  MPVolumeView.m
//  FlickStackr
//
//  Created by Carlos Mejía on 11-11-16.
//  Copyright (c) 2011 iPont. All rights reserved.
//

#import "MPVolumeView.h"

@implementation MPVolumeView
@synthesize showsVolumeSlider;
@synthesize showsRouteButton;
- (CGSize)sizeThatFits:(CGSize)size
{
    return CGSizeMake(0, 0);
}

@end
