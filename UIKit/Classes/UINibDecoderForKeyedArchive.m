#import "UINibDecoderForKeyedArchive.h"
#import "UINibInflationHelper.h"


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
    coder.delegate = [[[UINibInflationHelper alloc] initWithOwner:owner externalObjects:externalObjects] autorelease]; 
    return [coder autorelease];
}

@end