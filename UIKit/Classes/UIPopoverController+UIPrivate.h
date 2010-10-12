//  Created by Sean Heber on 8/16/10.
#import "UIPopoverController.h"

@class UIEvent;

@interface UIPopoverController (UIPrivate)
- (void)_setWindowTitle:(NSString *)title;
- (void)_popoverWindowControllerDidClosePopoverWindow:(id)controller;
- (BOOL)_popoverWindowControllerShouldClosePopoverWindow:(id)controller;
- (BOOL)_applicationShouldSendEvent:(UIEvent *)event;
@end
