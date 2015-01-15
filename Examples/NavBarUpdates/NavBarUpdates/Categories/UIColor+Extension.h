#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface UIColor (Extension)

+ (UIColor *)colorFromHexString:(NSString *)hexString;
- (BOOL)isEqualToColor:(UIColor *)otherColor;

@end
