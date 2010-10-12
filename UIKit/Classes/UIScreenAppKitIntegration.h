//  Created by Sean Heber on 10/12/10.
#import "UIScreen.h"

@interface UIScreen (UIAppKitIntegration)
// promotes this screen to the main screen
// this only changes what [UIScreen mainScreen] returns in the future, it doesn't move anything between views, etc.
- (void)becomeMainScreen;

// Using a nil screen will convert to OSX screen coordinates.
- (CGPoint)convertPoint:(CGPoint)toConvert toScreen:(UIScreen *)toScreen;
- (CGPoint)convertPoint:(CGPoint)toConvert fromScreen:(UIScreen *)fromScreen;
- (CGRect)convertRect:(CGRect)toConvert toScreen:(UIScreen *)toScreen;
- (CGRect)convertRect:(CGRect)toConvert fromScreen:(UIScreen *)fromScreen;
@end
