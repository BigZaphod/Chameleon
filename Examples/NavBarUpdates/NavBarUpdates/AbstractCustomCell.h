#import <UIKit/UIKit.h>

@interface AbstractCustomCell : UITableViewCell
- (void)setSelectedColor:(UIColor *)color;
- (void)mouseEntered:(UIView *)view withEvent:(UIEvent *)event;
- (void)mouseMoved:(UITouch *)touch withEvent:(UIEvent *)event;
- (void)mouseExited:(UIView *)view withEvent:(UIEvent *)event;
@end
