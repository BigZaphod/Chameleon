//  Created by Sean Heber on 8/16/10.
#import <Foundation/Foundation.h>

@class UIAccelerometer, UIAcceleration;

@protocol UIAccelerometerDelegate <NSObject>
- (void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration;
@end

@interface UIAccelerometer : NSObject {
@private
	NSTimeInterval _updateInterval;
	id<UIAccelerometerDelegate> _delegate;
}

+ (UIAccelerometer *)sharedAccelerometer;

@property (nonatomic, assign) id<UIAccelerometerDelegate> delegate;
@property (nonatomic) NSTimeInterval updateInterval;

@end
