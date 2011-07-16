#import "UINib.h"
#import "UINibLoading.h"
#import "UINibInflationHelper.h"
#import "UIRuntimeOutletConnection.h"
#import "UIRuntimeEventConnection.h"


static NSString* const kUINibTopLevelObjectsKey = @"UINibTopLevelObjectsKey";
static NSString* const kUINibConnectionsKey = @"UINibConnectionsKey";
static NSString* const kUINibObjectsKey = @"UINibObjectsKey";

static NSString* const kUINibAccessibilityConfigurationsKey = @"UINibAccessibilityConfigurationsKey";
static NSString* const kUINibKeyValuePairsKey = @"UINibKeyValuePairsKey";
static NSString* const kUINibVisibleWindowsKey = @"UINibVisibleWindowsKey";


@interface UINib ()
- (id) initWithData:(NSData*)data bundle:(NSBundle*)bundle;
@end


@implementation UINib {
    NSData* _data;
    NSBundle* _bundle;
}

+ (UINib*) nibWithData:(NSData*)data bundle:(NSBundle*)bundleOrNil
{
    if (!data) {
        return nil;
    }
    NSBundle* bundle = bundleOrNil ?: [NSBundle mainBundle];
    return [[[self alloc] initWithData:data bundle:bundle] autorelease];
}

+ (UINib*) nibWithNibName:(NSString*)name bundle:(NSBundle*)bundleOrNil
{
    NSBundle* bundle = bundleOrNil ?: [NSBundle mainBundle];
    NSString* pathToNib = [bundle pathForResource:name ofType:@"nib"];
    if (!pathToNib) {
        return nil;
    }
    NSData* data = [NSData dataWithContentsOfFile:pathToNib];
    if (!data) {
        return nil;
    }
    return [UINib nibWithData:data bundle:bundle];
}

- (void) dealloc
{
    [_data release];
    [_bundle release];
    [super dealloc];
}

- (id) initWithData:(NSData*)data bundle:(NSBundle*)bundle
{
    assert(data);
    assert(bundle);
    if (nil != (self = [super init])) {
        _data = [data retain];
        _bundle = [bundle retain];
    }
    return self;
}

- (NSArray*) instantiateWithOwner:(id)ownerOrNil options:(NSDictionary*)optionsOrNil
{
    NSArray* topLevelObjects = nil;
    NSKeyedUnarchiver* coder = [[NSKeyedUnarchiver alloc] initForReadingWithData:_data];
    if (coder) {
        id owner = ownerOrNil ?: [[[NSObject alloc] init] autorelease];
        coder.delegate = [[[UINibInflationHelper alloc] initWithOwner:owner externalObjects:[optionsOrNil objectForKey:UINibExternalObjects]] autorelease];
        @try {
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
        } @finally {
            [coder finishDecoding];
            [coder release];
        }
    }
    return topLevelObjects;
}

@end
