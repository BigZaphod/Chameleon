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
            return _owner;
        } else if ([proxiedObjectIdentifier isEqualToString:kIBFirstResponderKey]) {
            return [NSNull null];
        } else {
            return [_externalObjects objectForKey:proxiedObjectIdentifier];
        }
    }
    return nil;
}

@end
