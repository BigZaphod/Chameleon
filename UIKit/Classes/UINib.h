#import <Foundation/Foundation.h>


@interface UINib : NSObject

+ (UINib*) nibWithData:(NSData*)data bundle:(NSBundle*)bundleOrNil;
+ (UINib*) nibWithNibName:(NSString*)name bundle:(NSBundle*)bundleOrNil;

- (NSArray*) instantiateWithOwner:(id)ownerOrNil options:(NSDictionary*)optionsOrNil;

@end
