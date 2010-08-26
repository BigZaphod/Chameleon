//  Created by Sean Heber on 8/26/10.
#import <AppKit/NSTextView.h>

@class CALayer;

@interface UICustomNSTextView: NSTextView {
	BOOL secureTextEntry;
	__weak CALayer *parentLayer;
}

- (id)initWithFrame:(NSRect)frame secureTextEntry:(BOOL)isSecure;
- (void)setSecureTextEntry:(BOOL)isSecure;

@end
