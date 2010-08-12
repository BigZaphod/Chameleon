//  Created by Sean Heber on 6/1/10.
#import "CALayer+UIPrivate.h"
#import "UIView+UIPrivate.h"
#import <objc/runtime.h>

static IMP originalResizeMethod = NULL;

static IMP MethodSwizzle(Class c, SEL origSEL, SEL overrideSEL)
{
	Method origMethod = class_getInstanceMethod(c, origSEL);
	Method overrideMethod = class_getInstanceMethod(c, overrideSEL);
	
	if (class_addMethod(c, origSEL, method_getImplementation(overrideMethod), method_getTypeEncoding(overrideMethod))) {
		return class_replaceMethod(c, overrideSEL, method_getImplementation(origMethod), method_getTypeEncoding(origMethod));
	} else {
		IMP origIMP = method_getImplementation(origMethod);
		method_exchangeImplementations(origMethod, overrideMethod);
		return origIMP;
	}
}

@implementation CALayer (UIPrivate)

+ (void)load
{
	NSAutoreleasePool *pool = [NSAutoreleasePool new];
	originalResizeMethod = MethodSwizzle(self, @selector(resizeSublayersWithOldSize:), @selector(UIKitResizeSublayersWithOldSize:));
	[pool release];
}

- (void)UIPrivateResizeSublayersWithOldSize:(CGSize)size
{
	BOOL shouldResize = YES;
	
	if ([[self delegate] respondsToSelector:@selector(autoresizesSubviews)]) {
		shouldResize = [[self delegate] autoresizesSubviews];
	}
	
	if (shouldResize) {
		originalResizeMethod(self, @selector(resizeSublayersWithOldSize:), size);
	}
}

@end
