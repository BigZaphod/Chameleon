//
//  FDFlipsideViewController.h
//  IOSandMac_NoXib
//
//  Created by Dominik Pich on 07.02.13.
//  Copyright (c) 2013 Dominik Pich. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FDFlipsideViewController;

@protocol FDFlipsideViewControllerDelegate
- (void)flipsideViewControllerDidFinish:(FDFlipsideViewController *)controller;
@end

@interface FDFlipsideViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>
#if !__has_feature(objc_arc)
@property (assign, nonatomic) id <FDFlipsideViewControllerDelegate> delegate;
#else
@property (weak, nonatomic) id <FDFlipsideViewControllerDelegate> delegate;
#endif
@end
