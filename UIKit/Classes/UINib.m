#import "UINib.h"


static NSString* const kUINibTopLevelObjectsKey = @"UINibTopLevelObjectsKey";


@implementation UINib

+ (UINib*) nibWithData:(NSData*)data bundle:(NSBundle*)bundleOrNil
{
    if (!data) {
        return nil;
    }
    NSBundle* bundle = bundleOrNil ?: [NSBundle mainBundle];
    NSKeyedUnarchiver* coder = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    if (!coder) {
        return nil;
    }
    @try {
        NSArray* topLevelObjects = [coder decodeObjectForKey:kUINibTopLevelObjectsKey];
        NSLog(@"%@", topLevelObjects);
        
        
    } @catch (id exception) {
        NSLog(@"%@", exception);
        return nil;
    } @finally {
        [coder release];
    }
    return nil;
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

- (NSArray*) instantiateWithOwner:(id)ownerOrNil options:(NSDictionary*)optionsOrNil
{
    return nil;
}

@end
