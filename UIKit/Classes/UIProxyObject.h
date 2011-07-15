#import <Foundation/Foundation.h>

@interface UIProxyObject : NSObject <NSCoding>

@property (retain) NSString* proxiedObjectIdentifier;

+ (void) removeMappingsForCoder:(NSCoder*)coder;
+ (id) mappedObjectForCoder:(NSCoder*)coder withIdentifier:(NSString*)identifier;
+ (void) addMappings:(NSDictionary*)mappings forCoder:(NSCoder*)coder;
+ (void) addMappingFromIdentifier:(NSString*)identifier toObject:(NSString*)object forCoder:(NSCoder*)coder;
+ (CFDictionaryRef) proxyDecodingMap;

- (id) initWithCoder:(NSCoder*)coder;
- (void)encodeWithCoder:(NSCoder*)coder;

@end
