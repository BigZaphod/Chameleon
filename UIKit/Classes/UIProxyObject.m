#import "UIProxyObject.h"


static NSString* const kUIProxiedObjectIdentifierKey = @"UIProxiedObjectIdentifier";


@implementation UIProxyObject
@synthesize proxiedObjectIdentifier;

+ (void) removeMappingsForCoder:(NSCoder*)coder
{
    
}

+ (id) mappedObjectForCoder:(NSCoder*)coder withIdentifier:(NSString*)identifier
{
    return nil;
}

+ (void) addMappings:(NSDictionary*)mappings forCoder:(NSCoder*)coder
{
    
}

+ (void) addMappingFromIdentifier:(NSString*)identifier toObject:(NSString*)object forCoder:(NSCoder*)coder
{
    
}

+ (CFDictionaryRef) proxyDecodingMap
{
    return nil;
}

- (id) initWithCoder:(NSCoder*)coder
{
    if (nil != (self = [super init])) {
        self.proxiedObjectIdentifier = [coder decodeObjectForKey:kUIProxiedObjectIdentifierKey];
    }
    return self;
}

- (void) encodeWithCoder:(NSCoder*)coder
{
    [self doesNotRecognizeSelector:_cmd];
}

@end
