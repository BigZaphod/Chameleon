//  Created by Sean Heber on 6/29/10.
#import "UINavigationController.h"

enum {
	UIImagePickerControllerSourceTypePhotoLibrary,
	UIImagePickerControllerSourceTypeCamera,
	UIImagePickerControllerSourceTypeSavedPhotosAlbum
};
typedef NSUInteger UIImagePickerControllerSourceType;

extern NSString *const UIImagePickerControllerMediaType;
extern NSString *const UIImagePickerControllerOriginalImage;
extern NSString *const UIImagePickerControllerEditedImage;
extern NSString *const UIImagePickerControllerCropRect;
extern NSString *const UIImagePickerControllerMediaURL;

@protocol UIImagePickerControllerDelegate <NSObject>
@end

@interface UIImagePickerController : UINavigationController {
@private
	UIImagePickerControllerSourceType _sourceType;
	NSArray *_mediaTypes;
}

+ (NSArray *)availableMediaTypesForSourceType:(UIImagePickerControllerSourceType)sourceType;
+ (BOOL)isSourceTypeAvailable:(UIImagePickerControllerSourceType)sourceType;

@property (nonatomic) UIImagePickerControllerSourceType sourceType;
@property (nonatomic,assign) id <UINavigationControllerDelegate, UIImagePickerControllerDelegate> delegate;
@property (nonatomic,copy) NSArray *mediaTypes;

@end
