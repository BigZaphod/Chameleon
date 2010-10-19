//  Created by Sean Heber on 6/24/10.
#import "UIBezierPath.h"
#import <AppKit/AppKit.h>

@implementation UIBezierPath

+ (UIBezierPath *)_bezierPathWithNSBezierPath:(NSBezierPath *)thePath
{
	UIBezierPath *p = [UIBezierPath new];
	p->_path = [thePath retain];
	return [p autorelease];
}

- (void)dealloc
{
	[_path release];
	[super dealloc];
}

+ (UIBezierPath *)bezierPath
{
	return [self _bezierPathWithNSBezierPath:[NSBezierPath bezierPath]];
}

+ (UIBezierPath *)bezierPathWithRect:(CGRect)rect
{
	return [self _bezierPathWithNSBezierPath:[NSBezierPath bezierPathWithRect:NSRectFromCGRect(rect)]];
}

+ (UIBezierPath *)bezierPathWithRoundedRect:(CGRect)rect cornerRadius:(CGFloat)cornerRadius
{
	return [self _bezierPathWithNSBezierPath:[NSBezierPath bezierPathWithRoundedRect:NSRectFromCGRect(rect) xRadius:cornerRadius yRadius:cornerRadius]];
}

- (void)appendPath:(UIBezierPath *)bezierPath
{
	if (bezierPath) {
		[_path appendBezierPath:bezierPath->_path];
	}
}

- (void)addClip
{
	[_path addClip];
}

- (void)fill
{
	[_path fill];
}

@end
