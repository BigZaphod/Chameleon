#import "NSAttributedString+UIPrivate.h"
#import "UIColorAppKitIntegration.h"
#import "UIFontAppKitIntegration.h"
#import <AppKit/NSColor.h>
#import <AppKit/NSAttributedString.h>
#import <AppKit/NSFont.h>

@implementation NSAttributedString (UIPrivate)

- (NSAttributedString *)NSCompatibleAttributedString
{
    // convert UIColor and UIFont to NS counterparts
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:self.string];
    [self enumerateAttributesInRange:NSMakeRange(0, str.length) options:0 usingBlock:^(NSDictionary *attrs, NSRange range, BOOL *stop) {
        NSMutableDictionary *convertedAttrs = [NSMutableDictionary dictionaryWithCapacity:[attrs count]];
        [attrs enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            if ([obj isKindOfClass:[UIColor class]]) {
                obj = [(UIColor *)obj NSColor];
            } else if ([obj isKindOfClass:[UIFont class]]) {
                obj = [(UIFont *)obj NSFont];
            }
            
            convertedAttrs[key] = obj;
        }];
        [str setAttributes:convertedAttrs range:range];
    }];
    return str;
}
- (NSAttributedString *)UICompatibleAttributedString
{
    // convert NSColor and NSFont to UI counterparts
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:self.string];
    [self enumerateAttributesInRange:NSMakeRange(NSNotFound, 0) options:0 usingBlock:^(NSDictionary *attrs, NSRange range, BOOL *stop) {
        NSMutableDictionary *convertedAttrs = [NSMutableDictionary dictionaryWithCapacity:[attrs count]];
        [attrs enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            if ([obj isKindOfClass:[NSColor class]]) {
                obj = [UIColor colorWithNSColor:obj];
            } else if ([obj isKindOfClass:[NSFont class]]) {
                obj = [UIFont fontWithNSFont:obj];
            }
            
            convertedAttrs[key] = obj;
        }];
        [str setAttributes:convertedAttrs range:range];
    }];
    return str;
}

@end
