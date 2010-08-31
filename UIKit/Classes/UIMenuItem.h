//  Created by Sean Heber on 8/31/10.
#import <Foundation/Foundation.h>

@interface UIMenuItem : NSObject {
@private
	SEL _action;
	NSString *_title;
}

- (id)initWithTitle:(NSString *)title action:(SEL)action;

@property SEL action;
@property (copy) NSString *title;

@end
