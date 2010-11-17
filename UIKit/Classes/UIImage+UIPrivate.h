//  Created by Sean Heber on 8/11/10.
#import "UIImage.h"

@interface UIImage (UIPrivate)
+ (NSString *)_macPathForFile:(NSString *)path;		// inserts "@mac" into the filename of the file in the given path and returns the result
+ (NSString *)_pathForFile:(NSString *)path;		// uses above, checks for existence, if found, returns it otherwise returns the path string un-altered (doesn't verify that the file at the original path exists, though)

+ (void)_cacheImage:(UIImage *)image forName:(NSString *)name;
+ (UIImage *)_cachedImageForName:(NSString *)name;
+ (UIImage *)_backButtonImage;
+ (UIImage *)_highlightedBackButtonImage;
+ (UIImage *)_toolbarButtonImage;
+ (UIImage *)_highlightedToolbarButtonImage;
+ (UIImage *)_leftPopoverArrowImage;
+ (UIImage *)_rightPopoverArrowImage;
+ (UIImage *)_topPopoverArrowImage;
+ (UIImage *)_bottomPopoverArrowImage;
+ (UIImage *)_popoverBackgroundImage;
+ (UIImage *)_roundedRectButtonImage;
+ (UIImage *)_highlightedRoundedRectButtonImage;
+ (UIImage *)_windowResizeGrabberImage;
+ (UIImage *)_buttonBarSystemItemAdd;
+ (UIImage *)_buttonBarSystemItemReply;

- (UIImage *)_toolbarImage;		// returns a new image which is modified as required for toolbar buttons (turned into a solid color)
@end
