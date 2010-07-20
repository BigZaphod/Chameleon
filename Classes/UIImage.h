//  Created by Sean Heber on 5/27/10.
#import <Foundation/Foundation.h>

typedef enum {
	UIImageOrientationUp,
	UIImageOrientationDown,   // 180 deg rotation
	UIImageOrientationLeft,   // 90 deg CCW
	UIImageOrientationRight,   // 90 deg CW
	UIImageOrientationUpMirrored,    // as above but image mirrored along
	// other axis. horizontal flip
	UIImageOrientationDownMirrored,  // horizontal flip
	UIImageOrientationLeftMirrored,  // vertical flip
	UIImageOrientationRightMirrored, // vertical flip
} UIImageOrientation;

@interface UIImage : NSObject {
@private
	CGImageRef _image;
}

+ (UIImage *)imageNamed:(NSString *)name;
+ (UIImage *)imageWithData:(NSData *)data;
+ (UIImage *)imageWithContentsOfFile:(NSString *)path;
+ (UIImage *)imageWithCGImage:(CGImageRef)imageRef;

- (id)initWithData:(NSData *)data;
- (id)initWithContentsOfFile:(NSString *)path;
- (id)initWithCGImage:(CGImageRef)imageRef;

- (UIImage *)stretchableImageWithLeftCapWidth:(NSInteger)leftCapWidth topCapHeight:(NSInteger)topCapHeight;

- (void)drawAtPoint:(CGPoint)point blendMode:(CGBlendMode)blendMode alpha:(CGFloat)alpha;
- (void)drawInRect:(CGRect)rect blendMode:(CGBlendMode)blendMode alpha:(CGFloat)alpha;
- (void)drawAtPoint:(CGPoint)point;
- (void)drawInRect:(CGRect)rect;

@property (nonatomic, readonly) CGSize size;
@property (nonatomic, readonly) NSInteger leftCapWidth;
@property (nonatomic, readonly) NSInteger topCapHeight;
@property (nonatomic, readonly) CGImageRef CGImage;
@property (nonatomic, readonly) UIImageOrientation imageOrientation;	// not implemented

@end

void UIImageWriteToSavedPhotosAlbum(UIImage *image, id completionTarget, SEL completionSelector, void *contextInfo);
NSData * UIImageJPEGRepresentation(UIImage *image, CGFloat compressionQuality);
