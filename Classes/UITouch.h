//  Created by Sean Heber on 6/1/10.
#import <Foundation/Foundation.h>

typedef enum {
	UITouchPhaseBegan,
	UITouchPhaseMoved,
	UITouchPhaseStationary,
	UITouchPhaseEnded,
	UITouchPhaseCancelled,
} UITouchPhase;

@class UIView, UIWindow;

@interface UITouch : NSObject {
@private
	NSTimeInterval _timestamp;
	NSUInteger _tapCount;
	UITouchPhase _phase;
	CGPoint _location;
	CGPoint _previousLocation;
	UIView *_view;
	UIWindow *_window;
}

- (CGPoint)locationInView:(UIView *)inView;
- (CGPoint)previousLocationInView:(UIView *)inView;

@property (nonatomic, readonly) NSTimeInterval timestamp;
@property (nonatomic, readonly) NSUInteger tapCount;
@property (nonatomic, readonly) UITouchPhase phase;
@property (nonatomic, readonly, retain) UIView *view;
@property (nonatomic, readonly, retain) UIWindow *window;

@end
