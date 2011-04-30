//
//  UITableViewCellBackgroundView.h
//  UIKit
//
//  Created by Stéphane BARON on 29/04/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    UITableViewCellPositionUnique,
    UITableViewCellPositionTop,
    UITableViewCellPositionMiddle,
	UITableViewCellPositionBottom
} UITableViewCellPosition;

@interface UITableViewCellBackgroundView : UIView {
	
	unsigned int position;

}
@property (nonatomic, assign) unsigned int position;
@end
