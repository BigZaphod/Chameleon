//  Created by Sean Heber on 1/18/11.
#import <Foundation/Foundation.h>

@interface UIViewBlockAnimationDelegate : NSObject {
	void (^_completion)(BOOL finished);
	BOOL _interactionEventsAllowed;
}

@property (nonatomic, copy) void (^completion)(BOOL finished);
@property (nonatomic, assign) BOOL interactionEventsAllowed;

- (void)animationDidStop:(NSString *)animationID finished:(NSNumber *)finished;

@end
