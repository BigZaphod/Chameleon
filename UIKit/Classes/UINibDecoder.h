#import <Foundation/Foundation.h>


@interface UINibDecoder : NSObject

+ (UINibDecoder*) nibDecoderForData:(NSData*)data;

- (NSArray*) instantiateWithBundle:(NSBundle*)bundle owner:(id)owner externalObjects:(NSDictionary*)externalObjects;

@end
