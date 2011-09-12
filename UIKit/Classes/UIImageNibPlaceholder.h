#import "UIImage.h"

@interface UIImageNibPlaceholder : UIImage <NSCoding> {
    NSString *_resourceName;
    CGSize _size;
}
@property (nonatomic, readonly) NSString* resourceName;
@end
