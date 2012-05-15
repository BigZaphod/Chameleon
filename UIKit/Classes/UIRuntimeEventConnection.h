#import <Foundation/Foundation.h>
#import "UIControl.h"

@interface UIRuntimeEventConnection : NSObject <NSCoding> {
    UIControl *_control;
    id _target;
    SEL _action;
    UIControlEvents _eventMask;
}

@property (retain, nonatomic) UIControl* control;
@property (retain, nonatomic) id target;
@property (assign, nonatomic) SEL action;
@property (assign, nonatomic) UIControlEvents eventMask;

- (void) connect;

@end