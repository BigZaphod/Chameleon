//  Created by Sean Heber on 6/29/10.
#import "UIImagePickerController.h"

NSString *const UIImagePickerControllerMediaType = @"UIImagePickerControllerMediaType";
NSString *const UIImagePickerControllerOriginalImage = @"UIImagePickerControllerOriginalImage";
NSString *const UIImagePickerControllerEditedImage = @"UIImagePickerControllerEditedImage";
NSString *const UIImagePickerControllerCropRect = @"UIImagePickerControllerCropRect";
NSString *const UIImagePickerControllerMediaURL = @"UIImagePickerControllerMediaURL";

@implementation UIImagePickerController
@synthesize sourceType=_sourceType, mediaTypes=_mediaTypes;
@dynamic delegate;

+ (NSArray *)availableMediaTypesForSourceType:(UIImagePickerControllerSourceType)sourceType
{
	return nil;
}

+ (BOOL)isSourceTypeAvailable:(UIImagePickerControllerSourceType)sourceType
{
	return NO;
}

- (void)dealloc
{
	[_mediaTypes release];
	[super dealloc];
}

@end
