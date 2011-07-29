#import <Foundation/Foundation.h>


@interface UINibDecoder : NSObject

+ (UINibDecoder*) nibDecoderForData:(NSData*)data;

- (NSArray*) instantiateWithOwner:(id)owner externalObjects:(NSDictionary*)externalObjects;

@end
