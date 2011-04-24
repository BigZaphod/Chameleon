//
//  UITabBarButtonBadge.m
//  UIKit
//
//  Created by Faustino Osuna on 4/24/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "UITabBarButtonBadge.h"
#import "UIFont.h"
#import "UIColor.h"
#import "UIImage+UIPrivate.h"
#import "UIImageView.h"

@implementation UITabBarButtonBadge

- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame])) {
        UIImage *backgroundImage = [UIImage _tabBarButtonBadgeImage];
        UIImageView *backgroundView = [[UIImageView alloc] initWithImage:backgroundImage];
        [backgroundView setFrame:self.bounds];
        [backgroundView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
        [self addSubview:backgroundView];
        [backgroundView release];

        _title = [[UILabel alloc] init];
        _title.font = [UIFont systemFontOfSize:11.0f];
        _title.textColor = [UIColor whiteColor];
        _title.textAlignment = UITextAlignmentCenter;
        _title.opaque = NO;
        _title.backgroundColor = [UIColor clearColor];
        [self addSubview:_title];
    }

    return self;
}

- (void)dealloc
{
    [_title release];
    [super dealloc];
}

- (NSString *)text
{
   return _title.text;
}

- (void)setText:(NSString *)text
{
    _title.text = text;
}

- (CGSize)sizeThatFits:(CGSize)size
{
    CGSize imageSize = [UIImage _tabBarButtonBadgeImage].size;
    CGSize textSize =  [_title sizeThatFits:size];

    return CGSizeMake(MAX(textSize.width + 8.0f, imageSize.width),
                      MAX(textSize.height + 4.0f, imageSize.height));
}

- (void)layoutSubviews
{
    [super layoutSubviews];

    const CGSize boundSize = self.bounds.size;
    const CGSize titleSize = [_title sizeThatFits:CGSizeMake(boundSize.width - 8.0f, boundSize.height - 4.0f)];
    CGRect titleFrame = CGRectMake(roundf((boundSize.width - titleSize.width) / 2.0f),
                                   roundf((boundSize.height - titleSize.height) / 2.0f) - 1.0f,
                                   titleSize.width, titleSize.height);
    [_title setFrame:titleFrame];
}
@end
