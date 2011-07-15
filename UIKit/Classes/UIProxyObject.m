#import "UIProxyObject.h"

@implementation UIProxyObject
@synthesize proxiedObjectIdentifier;

+ (void)removeMappingsForCoder:(id)arg1
{
    
}

+ (id)mappedObjectForCoder:(id)arg1 withIdentifier:(id)arg2
{
    return nil;
}

+ (void)addMappings:(id)arg1 forCoder:(id)arg2
{
    
}

+ (void)addMappingFromIdentifier:(id)arg1 toObject:(id)arg2 forCoder:(id)arg3
{
    
}

+ (CFDictionaryRef)proxyDecodingMap
{
    return nil;
}

- (id) initWithCoder:(NSCoder*)coder
{
    if (nil != (self = [super init])) {
        self.proxiedObjectIdentifier = [coder decodeObjectForKey:@"UIProxiedObjectIdentifier"];
    }
    return nil;
}

- (void) encodeWithCoder:(NSCoder*)coder
{
    [self doesNotRecognizeSelector:_cmd];
}

@end
