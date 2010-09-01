//  Created by Sean Heber on 6/1/10.
#import <Foundation/Foundation.h>

typedef enum {
	UIEventTypeTouches,
	UIEventTypeMotion,
	_UIEventTypeMouseScroll,
	_UIEventTypeMouseMoved,
	_UIEventTypeMouseRightClick,
} UIEventType;

typedef enum {
	UIEventSubtypeNone        = 0,
	UIEventSubtypeMotionShake = 1,
} UIEventSubtype;

@class UITouch, UIWindow, UIView, NSEvent;

@interface UIEvent : NSObject {
@private
	NSEvent *_event;
	UITouch *_touch;
	UIView *_previousMouseMovementView;
}

@property (nonatomic, readonly) NSTimeInterval timestamp;

- (NSSet *)allTouches;
- (NSSet *)touchesForView:(UIView *)view;
- (NSSet *)touchesForWindow:(UIWindow *)window;

@property (nonatomic, readonly) UIEventType type;
@property (nonatomic, readonly) UIEventSubtype subtype;

@end
