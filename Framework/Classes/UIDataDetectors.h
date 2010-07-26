//  Created by Sean Heber on 6/29/10.
#import <Foundation/Foundation.h>

enum {
	UIDataDetectorTypePhoneNumber   = 1 << 0,
	UIDataDetectorTypeLink          = 1 << 1,
	
	UIDataDetectorTypeNone          = 0,
	UIDataDetectorTypeAll           = NSUIntegerMax
};
typedef NSUInteger UIDataDetectorTypes;
