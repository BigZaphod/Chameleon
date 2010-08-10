//  Created by Sean Heber on 6/25/10.
#import <Foundation/Foundation.h>

@class UIImage;

@interface UIBarItem : NSObject {
@private
	BOOL _enabled;
	UIImage *_image;
	NSString *_title;
	NSInteger _tag;
}

@property (nonatomic, getter=isEnabled) BOOL enabled;
@property (nonatomic, retain) UIImage *image;
@property (nonatomic, copy) NSString *title;
@property (nonatomic) NSInteger tag;

@end
