#import <Foundation/Foundation.h>

@interface UIProxyObject : NSObject <NSCoding>

@property (retain) NSString* proxiedObjectIdentifier;

+ (void)removeMappingsForCoder:(id)arg1;
+ (id)mappedObjectForCoder:(id)arg1 withIdentifier:(id)arg2;
+ (void)addMappings:(id)arg1 forCoder:(id)arg2;
+ (void)addMappingFromIdentifier:(id)arg1 toObject:(id)arg2 forCoder:(id)arg3;
+ (CFDictionaryRef)proxyDecodingMap;

- (id) initWithCoder:(NSCoder*)coder;
- (void)encodeWithCoder:(NSCoder*)coder;

@end
