//  Created by Sean Heber on 6/25/10.
#import <Foundation/Foundation.h>

@interface UIScreenMode : NSObject {
	CGFloat _pixelAspectRatio;
	CGSize _size;
}

@property (readonly,nonatomic) CGFloat pixelAspectRatio;
@property (readonly,nonatomic) CGSize size;

@end
