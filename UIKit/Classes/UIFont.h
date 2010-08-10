//  Created by Sean Heber on 6/17/10.
#import <Foundation/Foundation.h>

@interface UIFont : NSObject {
@package
	CTFontRef _font;
}

+ (UIFont *)fontWithName:(NSString *)fontName size:(CGFloat)fontSize;
+ (UIFont *)systemFontOfSize:(CGFloat)fontSize;
+ (UIFont *)boldSystemFontOfSize:(CGFloat)fontSize;

- (UIFont *)fontWithSize:(CGFloat)fontSize;

@property (nonatomic, readonly, retain) NSString *fontName;

@property (nonatomic, readonly) CGFloat ascender;
@property (nonatomic, readonly) CGFloat descender;
@property (nonatomic, readonly) CGFloat leading;		// deprecated in 4.0 because it was actually returning the value of lineHeight (which was added in 4.0)
@property (nonatomic, readonly) CGFloat lineHeight;		// added in 4.0
@property (nonatomic, readonly) CGFloat pointSize;
@property (nonatomic, readonly) CGFloat xHeight;
@property (nonatomic, readonly) CGFloat capHeight;
@property (nonatomic, readonly, retain) NSString *familyName;

@end
