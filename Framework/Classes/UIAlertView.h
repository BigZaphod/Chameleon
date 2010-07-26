//  Created by Sean Heber on 6/25/10.
#import "UIView.h"

@protocol UIAlertViewDelegate <NSObject>
@end

@interface UIAlertView : UIView {
@private
	NSInteger _cancelButtonIndex;
}

- (id)initWithTitle:(NSString *)title message:(NSString *)message delegate:(id)delegate cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSString *)otherButtonTitles, ...;

- (void)show;

@property (nonatomic) NSInteger cancelButtonIndex;

@end
