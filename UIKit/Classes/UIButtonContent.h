#import <Foundation/Foundation.h>

@class UIColor, UIImage;

@interface UIButtonContent : NSObject <NSCoding, NSCopying>

@property (retain, nonatomic) UIColor* shadowColor;
@property (retain, nonatomic) UIColor* titleColor;
@property (retain, nonatomic) UIImage* backgroundImage;
@property (retain, nonatomic) UIImage* image;
@property (retain, nonatomic) NSString* title;

@end
