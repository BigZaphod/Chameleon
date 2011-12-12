#import "UINib.h"
#import "UINibLoading.h"
#import "UINibDecoder.h"
#import "UIRuntimeOutletConnection.h"
#import "UIRuntimeEventConnection.h"


@interface UINib ()
- (id) initWithData:(NSData*)data bundle:(NSBundle*)bundle;
@end


@implementation UINib 

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
    [_decoder release];
    [super dealloc];
}

- (id) initWithData:(NSData*)data bundle:(NSBundle*)bundle
{
    assert(data);
    assert(bundle);
    if (nil != (self = [super init])) {
        _data = [data retain];
        _bundle = [bundle retain];
        _decoder = [[UINibDecoder nibDecoderForData:_data] retain];
    }
    return self;
}

- (NSArray*) instantiateWithOwner:(id)ownerOrNil options:(NSDictionary*)optionsOrNil
{    
    id owner = ownerOrNil ?: [[[NSObject alloc] init] autorelease];
    NSDictionary* externalObjects = [optionsOrNil objectForKey:UINibExternalObjects];
    return [_decoder instantiateWithBundle:_bundle owner:owner externalObjects:externalObjects];
}

@end
