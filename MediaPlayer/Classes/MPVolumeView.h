//
//  MPVolumeView.h
//  FlickStackr
//
//  Created by Carlos Mejía on 11-11-16.
//  Copyright (c) 2011 iPont. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MPVolumeView : UIView  
{
}

- (CGSize)sizeThatFits:(CGSize)size;

@property (nonatomic) BOOL showsVolumeSlider; // Default is YES.
@property (nonatomic) BOOL showsRouteButton;  // Default is YES.

@end
