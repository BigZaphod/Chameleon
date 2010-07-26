//  Created by Sean Heber on 6/25/10.
#import <Foundation/Foundation.h>

@class UIImage;

@interface UIBarItem : NSObject {
@private
	BOOL _enabled;
	UIImage *_image;
}

@property (nonatomic, getter=isEnabled) BOOL enabled;
@property (nonatomic, retain) UIImage *image;

@end
