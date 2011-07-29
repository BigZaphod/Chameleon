#import "UINibDecoderForKeyedArchive.h"
#import "UIProxyObject.h"


static NSString* const kIBFilesOwnerKey = @"IBFilesOwner";
static NSString* const kIBFirstResponderKey = @"IBFirstResponder";


@interface UIKeyedArchiveNibInflationHelper : NSObject <NSKeyedUnarchiverDelegate>

- (id) initWithOwner:(id)owner externalObjects:(NSDictionary*)externalObjects;

@end


@implementation UINibDecoderForKeyedArchive {
    NSData* _data;
}

- (void) dealloc
{
    [_data release];
    [super dealloc];
}

- (id) initWithData:(NSData*)data
{
    assert(data);
    if (nil != (self = [super init])) {
        _data = [data retain];
    }
    return self;
}

- (NSCoder*) instantiateCoderWithOwner:(id)owner externalObjects:(NSDictionary*)externalObjects
{
    NSKeyedUnarchiver* coder = [[NSKeyedUnarchiver alloc] initForReadingWithData:_data];
    coder.delegate = [[[UIKeyedArchiveNibInflationHelper alloc] initWithOwner:owner externalObjects:externalObjects] autorelease]; 
    return [coder autorelease];
}

@end


@implementation UIKeyedArchiveNibInflationHelper {
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
            return [_owner retain]; 
        } else if ([proxiedObjectIdentifier isEqualToString:kIBFirstResponderKey]) {
            return [[NSNull null] retain];
        } else {
            return [[_externalObjects objectForKey:proxiedObjectIdentifier] retain];
        }
    }
    return nil;
}

@end
