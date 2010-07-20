//  Created by Sean Heber on 7/7/10.
#import "UIAccessibility.h"

@interface UIAccessibilityElement : NSObject {
	NSString *_accessibilityLabel;
	NSString *_accessibilityHint;
	NSString *_accessibilityValue;
	CGRect _accessibilityFrame;
	UIAccessibilityTraits _accessibilityTraits;
}

- (id)initWithAccessibilityContainer:(id)container;

@property (nonatomic, retain) NSString *accessibilityLabel;
@property (nonatomic, retain) NSString *accessibilityHint;
@property (nonatomic, retain) NSString *accessibilityValue;
@property (nonatomic, assign) CGRect accessibilityFrame;
@property (nonatomic, assign) UIAccessibilityTraits accessibilityTraits;

@end
