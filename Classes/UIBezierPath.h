//  Created by Sean Heber on 6/24/10.
#import <Foundation/Foundation.h>

@class NSBezierPath;

@interface UIBezierPath : NSObject {
@private
	NSBezierPath *_path;
}

+ (UIBezierPath *)bezierPathWithRoundedRect:(CGRect)rect cornerRadius:(CGFloat)cornerRadius;

- (void)addClip;
- (void)fill;

@end
