//  Created by Sean Heber on 11/22/10.
#import "UIControl.h"

@interface UIControlAction : NSObject {
	id target;
	SEL action;
	UIControlEvents controlEvents;
}

@property (nonatomic, assign) id target;
@property (nonatomic, assign) SEL action;
@property (nonatomic, assign) UIControlEvents controlEvents;

@end
