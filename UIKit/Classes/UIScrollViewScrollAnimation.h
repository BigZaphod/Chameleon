//  Created by Sean Heber on 1/11/11.
#import <Foundation/Foundation.h>

@interface UIScrollViewScrollAnimation : NSObject {
	CGPoint contentOffsetVelocity;
	NSTimeInterval stopTime;
}

@property (nonatomic, assign) CGPoint contentOffsetVelocity;
@property (nonatomic, assign) NSTimeInterval stopTime;

@end
