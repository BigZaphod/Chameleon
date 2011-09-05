#import <Foundation/Foundation.h>
#import "UIControl.h"

@interface UIRuntimeEventConnection : NSObject <NSCoding>

@property (retain, nonatomic) UIControl* control;
@property (retain, nonatomic) id target;
@property (assign, nonatomic) SEL action;
@property (assign, nonatomic) UIControlEvents eventMask;

- (void) connect;

@end