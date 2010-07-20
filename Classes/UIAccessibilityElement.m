//  Created by Sean Heber on 7/7/10.
#import "UIAccessibilityElement.h"

@implementation UIAccessibilityElement
@synthesize accessibilityLabel=_accessibilityLabel, accessibilityHint=_accessibilityHint, accessibilityValue=_accessibilityValue;
@synthesize accessibilityFrame=_accessibilityFrame, accessibilityTraits=_accessibilityTraits;

- (id)initWithAccessibilityContainer:(id)container
{
	if ((self=[super init])) {
	}
	return self;
}

- (void)dealloc
{
	[_accessibilityLabel release];
	[_accessibilityHint release];
	[_accessibilityValue release];
	[super dealloc];
}

@end
