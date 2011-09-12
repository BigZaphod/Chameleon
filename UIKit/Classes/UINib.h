#import <Foundation/Foundation.h>

@class UINibDecoder;
@interface UINib : NSObject {
    NSData* _data;
    NSBundle* _bundle;
    UINibDecoder* _decoder;
}

+ (UINib*) nibWithData:(NSData*)data bundle:(NSBundle*)bundleOrNil;
+ (UINib*) nibWithNibName:(NSString*)name bundle:(NSBundle*)bundleOrNil;

- (NSArray*) instantiateWithOwner:(id)ownerOrNil options:(NSDictionary*)optionsOrNil;

@end
