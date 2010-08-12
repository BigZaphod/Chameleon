//  Created by Sean Heber on 8/12/10.
#import "UIControl.h"

@interface UISwitch : UIControl {
}

- (id)initWithFrame:(CGRect)frame;
- (void)setOn:(BOOL)on animated:(BOOL)animated;

@property(nonatomic, getter=isOn) BOOL on;

@end
