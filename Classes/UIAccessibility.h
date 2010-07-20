//  Created by Sean Heber on 6/21/10.
#import <Foundation/Foundation.h>

typedef uint64_t UIAccessibilityTraits;

extern UIAccessibilityTraits UIAccessibilityTraitNone;
extern UIAccessibilityTraits UIAccessibilityTraitButton;
extern UIAccessibilityTraits UIAccessibilityTraitLink;
extern UIAccessibilityTraits UIAccessibilityTraitSearchField;
extern UIAccessibilityTraits UIAccessibilityTraitImage;
extern UIAccessibilityTraits UIAccessibilityTraitSelected;
extern UIAccessibilityTraits UIAccessibilityTraitPlaysSound;
extern UIAccessibilityTraits UIAccessibilityTraitKeyboardKey;
extern UIAccessibilityTraits UIAccessibilityTraitStaticText;
extern UIAccessibilityTraits UIAccessibilityTraitSummaryElement;
extern UIAccessibilityTraits UIAccessibilityTraitNotEnabled;
extern UIAccessibilityTraits UIAccessibilityTraitUpdatesFrequently;


typedef uint32_t UIAccessibilityNotifications;
extern UIAccessibilityNotifications UIAccessibilityScreenChangedNotification;
extern UIAccessibilityNotifications UIAccessibilityLayoutChangedNotification;


@interface NSObject (UIAccessibility)
- (BOOL)isAccessibilityElement;
- (void)setIsAccessibilityElement:(BOOL)isElement;
- (NSString *)accessibilityLabel;
- (void)setAccessibilityLabel:(NSString *)label;
/*
- (NSString *)accessibilityHint;
- (void)setAccessibilityHint:(NSString *)hint;
- (NSString *)accessibilityValue;
- (void)setAccessibilityValue:(NSString *)value;
- (UIAccessibilityTraits)accessibilityTraits;
- (void)setAccessibilityTraits:(UIAccessibilityTraits)traits;
- (CGRect)accessibilityFrame;
- (void)setAccessibilityFrame:(CGRect)frame;
 */
@end

/*
@interface NSObject (UIAccessibilityContainer)
- (NSInteger)accessibilityElementCount;
- (id)accessibilityElementAtIndex:(NSInteger)index;
- (NSInteger)indexOfAccessibilityElement:(id)element;
@end
*/

extern void UIAccessibilityPostNotification(UIAccessibilityNotifications notification, id argument);
extern BOOL UIAccessibilityIsVoiceOverRunning();
