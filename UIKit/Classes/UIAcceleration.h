//  Created by Sean Heber on 8/16/10.
#import <Foundation/Foundation.h>

typedef double UIAccelerationValue;

@interface UIAcceleration : NSObject {
	UIAccelerationValue _x;
	UIAccelerationValue _y;
	UIAccelerationValue _z;
	NSTimeInterval _timestamp;
}

@property (nonatomic, readonly) UIAccelerationValue x;
@property (nonatomic, readonly) UIAccelerationValue y;
@property (nonatomic, readonly) UIAccelerationValue z;
@property (nonatomic, readonly) NSTimeInterval timestamp;

@end
