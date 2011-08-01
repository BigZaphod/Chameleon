#import "UINibDecoder.h"
#import "UINibDecoderForKeyedArchive.h"
#import "UINibDecoderForNibArchiveV1.h"
#import "UIRuntimeOutletConnection.h"
#import "UIRuntimeEventConnection.h"
#import "UINibLoading.h"


static NSString* const kUINibAccessibilityConfigurationsKey = @"UINibAccessibilityConfigurationsKey";
static NSString* const kUINibConnectionsKey = @"UINibConnectionsKey";
static NSString* const kUINibKeyValuePairsKey = @"UINibKeyValuePairsKey";
static NSString* const kUINibObjectsKey = @"UINibObjectsKey";
static NSString* const kUINibTopLevelObjectsKey = @"UINibTopLevelObjectsKey";
static NSString* const kUINibVisibleWindowsKey = @"UINibVisibleWindowsKey";


@implementation UINibDecoder

+ (UINibDecoder*) nibDecoderForData:(NSData*)data
{
    assert(data);

    NSUInteger length = [data length];

    void const* header = [data bytes];
    if (length >= 0x0A && 0 == (memcmp(header, "NIBArchive", 0x0A))) {
        uint32_t version = OSReadLittleInt32(header, 0x0A);
        uint32_t encoderVersion = OSReadLittleInt32(header, 0x0E);
        
        NSString* decoderClassName = [NSString stringWithFormat:@"UINibDecoderForNibArchiveV%d", version];
        Class decoderClass = NSClassFromString(decoderClassName);
        if (!decoderClass) {
            return nil;
        }
        
        return [[[decoderClass alloc] initWithData:data encoderVersion:encoderVersion] autorelease];
    } else {
        return [[[UINibDecoderForKeyedArchive alloc] initWithData:data] autorelease];
    }
}

- (NSCoder*) instantiateCoderWithBundle:(NSBundle*)bundle owner:(id)owner externalObjects:(NSDictionary*)externalObjects
{
    return nil;
}

- (NSArray*) instantiateWithBundle:(NSBundle*)bundle owner:(id)owner externalObjects:(NSDictionary*)externalObjects
{
    NSArray* topLevelObjects = nil;
    NSCoder* coder = [self instantiateCoderWithBundle:bundle owner:owner externalObjects:externalObjects];
    if (coder) {
        BOOL referencedOwner = NO;
        for (id connection in [coder decodeObjectForKey:kUINibConnectionsKey]) {
            if ([connection isKindOfClass:[UIRuntimeOutletConnection class]]) {
                if ([connection target] == owner) {
                    referencedOwner = YES;
                }
                [connection connect];
            } else if ([connection isKindOfClass:[UIRuntimeEventConnection class]]) {
                [connection connect];
            } else {
                // Warn?
            }
        }
        
        for (id object in [coder decodeObjectForKey:kUINibObjectsKey]) {
            if ([object respondsToSelector:@selector(awakeFromNib)]) {
                [object awakeFromNib];
            }
        }
        
        NSArray* rawTopLevel = [coder decodeObjectForKey:kUINibTopLevelObjectsKey];
        if (rawTopLevel.count < 2) {
            return nil;
        }
        NSMutableArray* mutableTopLevel = [rawTopLevel mutableCopy];
        [mutableTopLevel removeObjectAtIndex:1];
        if (!referencedOwner) {
            [mutableTopLevel removeObjectAtIndex:0];
        }
        topLevelObjects = [NSArray arrayWithArray:mutableTopLevel];
        [mutableTopLevel release];
    }
    return topLevelObjects;
}

@end
