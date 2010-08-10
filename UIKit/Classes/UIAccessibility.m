//  Created by Sean Heber on 6/21/10.
#import "UIAccessibility.h"

UIAccessibilityTraits UIAccessibilityTraitNone = 0;
UIAccessibilityTraits UIAccessibilityTraitButton = 1;
UIAccessibilityTraits UIAccessibilityTraitLink = 2;
UIAccessibilityTraits UIAccessibilityTraitImage = 4;
UIAccessibilityTraits UIAccessibilityTraitSelected = 8;
UIAccessibilityTraits UIAccessibilityTraitPlaysSound = 16;
UIAccessibilityTraits UIAccessibilityTraitKeyboardKey = 32;
UIAccessibilityTraits UIAccessibilityTraitStaticText = 64;
UIAccessibilityTraits UIAccessibilityTraitSummaryElement = 128;
UIAccessibilityTraits UIAccessibilityTraitNotEnabled = 256;
UIAccessibilityTraits UIAccessibilityTraitUpdatesFrequently = 512;
UIAccessibilityTraits UIAccessibilityTraitSearchField = 1024;

UIAccessibilityNotifications UIAccessibilityScreenChangedNotification = 1000;
UIAccessibilityNotifications UIAccessibilityLayoutChangedNotification = 1001;


@implementation NSObject (UIAccessibility)
- (BOOL)isAccessibilityElement
{
	return NO;
}

- (void)setIsAccessibilityElement:(BOOL)isElement
{
}

- (NSString *)accessibilityLabel
{
	return nil;
}

- (void)setAccessibilityLabel:(NSString *)label
{
}
@end

void UIAccessibilityPostNotification(UIAccessibilityNotifications notification, id argument)
{
}

BOOL UIAccessibilityIsVoiceOverRunning()
{
	return NO;
}
