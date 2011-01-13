//  Created by Sean Heber on 6/1/10.
#import <Foundation/Foundation.h>

typedef enum {
	UIEventTypeTouches,
	UIEventTypeMotion,
	UIEventTypeKeyPress			// nonstandard
} UIEventType;

typedef enum {
	UIEventSubtypeNone        = 0,
	UIEventSubtypeMotionShake = 1,
} UIEventSubtype;

@class UITouch, UIWindow, UIView;

@interface UIEvent : NSObject {
@private
	UIEventType _type;
	UITouch *_touch;
	NSTimeInterval _timestamp;
	BOOL _unhandledKeyPressEvent;
}

@property (nonatomic, readonly) NSTimeInterval timestamp;

- (NSSet *)allTouches;
- (NSSet *)touchesForView:(UIView *)view;
- (NSSet *)touchesForWindow:(UIWindow *)window;

@property (nonatomic, readonly) UIEventType type;
@property (nonatomic, readonly) UIEventSubtype subtype;

@end
