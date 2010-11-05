//  Created by Sean Heber on 6/24/10.
#import <Foundation/Foundation.h>

@class NSBezierPath;

@interface UIBezierPath : NSObject {
@private
	NSBezierPath *_path;
}

+ (UIBezierPath *)bezierPath;
+ (UIBezierPath *)bezierPathWithRect:(CGRect)rect;
+ (UIBezierPath *)bezierPathWithRoundedRect:(CGRect)rect cornerRadius:(CGFloat)cornerRadius;

- (void)appendPath:(UIBezierPath *)bezierPath;

- (void)addClip;
- (void)fill;
- (void)stroke;

@property (nonatomic) CGFloat lineWidth;

@end
