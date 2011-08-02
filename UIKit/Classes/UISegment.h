#import "UIImageView.h"

@interface UISegment : UIImageView <NSCoding> {
    NSString *_title;
    NSInteger _position;
}
@property (nonatomic, copy) NSString *title;
@property (nonatomic, assign) NSInteger position;
@end
