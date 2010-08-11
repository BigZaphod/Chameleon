//  Created by Sean Heber on 6/1/10.
#import "CALayer+UIKit.h"
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

@implementation CALayer (UIKit)

+ (void)load
{
	originalResizeMethod = MethodSwizzle(self, @selector(resizeSublayersWithOldSize:), @selector(UIKitResizeSublayersWithOldSize:));
}

- (void)UIKitResizeSublayersWithOldSize:(CGSize)size
{
	BOOL shouldResize = YES;
	
	if ([[self delegate] respondsToSelector:@selector(autoresizesSubviews)]) {
		shouldResize = [[self delegate] autoresizesSubviews];
	}
	
	if (shouldResize) {
		originalResizeMethod(self, @selector(resizeSublayersWithOldSize:), size);
	}
}

/*
+ (CALayer *)UIKitCommonParentForLayers:(NSArray *)layers
{
	CALayer *parent = nil;
	NSMutableDictionary *referenceTracker = [NSMutableDictionary new];
	NSMutableDictionary *depthTracker = [NSMutableDictionary new];

	for (CALayer *layer in layers) {
		NSUInteger depth = 0;
		do {
			NSValue *key = [NSValue valueWithNonretainedObject:layer];
			
			{
				NSNumber *referenceCount = [referenceTracker objectForKey:key];
				if (referenceCount) {
					referenceCount = [NSNumber numberWithInt:[referenceCount intValue]+1];
				} else {
					referenceCount = [NSNumber numberWithInt:1];
				}
				[referenceTracker setObject:referenceCount forKey:key];
			}

			{
				NSNumber *depthCount = [depthTracker objectForKey:key];
				if (depthCount) {
					depthCount = [NSNumber numberWithInt:[depthCount intValue]+depth];
				} else {
					depthCount = [NSNumber numberWithInt:depth];
				}
				[depthTracker setObject:depthCount forKey:key];
			}
			
			layer = [layer superlayer];
			depth++;
		} while (layer);
	}
	
	// Now check to see if there's a single layer in the tracker dictionary that has [layers count] references.
	// Do this by preferring the layer that is least deep.

	for (NSValue *key in [depthTracker keysSortedByValueUsingSelector:@selector(compare:)]) {
		NSNumber *count = [referenceTracker objectForKey:key];
		if ([count intValue] == [layers count]) {
			parent = [key nonretainedObjectValue];
			break;
		}
	}
	
	[referenceTracker release];
	[depthTracker release];
	return parent;
}
*/

@end
