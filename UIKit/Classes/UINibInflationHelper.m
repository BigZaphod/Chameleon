#import "UINibInflationHelper.h"
#import "UIProxyObject.h"


static NSString* const kIBFilesOwnerKey = @"IBFilesOwner";
static NSString* const kIBFirstResponderKey = @"IBFirstResponder";


@implementation UINibInflationHelper {
    id _owner;
    NSDictionary* _externalObjects;
}

- (void) dealloc
{
    [_owner release];
    [_externalObjects release];
    [super dealloc];
}

- (id) initWithOwner:(id)owner externalObjects:(NSDictionary*)externalObjects
{
    if (nil != (self = [super init])) {
        _owner = [owner retain];
        _externalObjects = [externalObjects retain];
    }
    return self;
}


#pragma mark

- (id) unarchiver:(NSKeyedUnarchiver*)unarchiver didDecodeObject:(id)object
{
    if ([object isKindOfClass:[UIProxyObject class]]) {
        NSString* proxiedObjectIdentifier = [object proxiedObjectIdentifier];
        if ([proxiedObjectIdentifier isEqualToString:kIBFilesOwnerKey]) {
            object = _owner;
        } else if ([proxiedObjectIdentifier isEqualToString:kIBFirstResponderKey]) {
            object = [NSNull null];
        } else {
            object = [_externalObjects objectForKey:proxiedObjectIdentifier];
        }
    }
    return object;
}

@end
