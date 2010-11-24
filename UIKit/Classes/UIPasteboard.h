//  Created by Sean Heber on 6/25/10.
#import <Foundation/Foundation.h>

@class UIImage, UIColor, NSPasteboard;

@interface UIPasteboard : NSObject {
	NSPasteboard *pasteboard;
}

+ (UIPasteboard *)generalPasteboard;

@property (nonatomic,copy) NSURL *URL;
@property (nonatomic,copy) NSArray *URLs;
@property (nonatomic,copy) NSString *string;
@property (nonatomic,copy) NSArray *strings;
@property (nonatomic, copy) UIImage *image;
@property (nonatomic, copy) NSArray *images;
@property (nonatomic, copy) UIColor *color;
@property (nonatomic, copy) NSArray *colors;
@property (nonatomic, copy) NSArray *items;

@end
