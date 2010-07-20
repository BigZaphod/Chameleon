//  Created by Sean Heber on 6/25/10.
#import <Foundation/Foundation.h>

@class UIImage;

@interface UIPasteboard : NSObject {
}

+ (UIPasteboard *)generalPasteboard;

@property (nonatomic, copy) UIImage *image;
@property (nonatomic, copy) NSArray *items;

@end
