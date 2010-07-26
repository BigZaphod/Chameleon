//  Created by Sean Heber on 6/25/10.
#import "UIView.h"

@class UIColor, UINavigationItem;

@interface UINavigationBar : UIView {
@private
	UIColor *_tintColor;
}

@property (nonatomic, retain) UIColor *tintColor;
@property (nonatomic, readonly, retain) UINavigationItem *topItem;

@end
