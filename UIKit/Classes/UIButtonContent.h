#import <Foundation/Foundation.h>

@class UIColor, UIImage;

@interface UIButtonContent : NSObject <NSCoding, NSCopying> {
    UIColor * _shadowColor;
    UIColor *_titleColor;
    UIImage *_backgroundImage;
    UIImage *_image;
    NSString *_title;
}

@property (retain, nonatomic) UIColor *shadowColor;
@property (retain, nonatomic) UIColor *titleColor;
@property (retain, nonatomic) UIImage *backgroundImage;
@property (retain, nonatomic) UIImage *image;
@property (retain, nonatomic) NSString *title;

@end
