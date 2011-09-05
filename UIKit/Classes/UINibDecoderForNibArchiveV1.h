#import "UINibDecoder.h"


@interface UINibDecoderForNibArchiveV1 : UINibDecoder

- (id) initWithData:(NSData*)data encoderVersion:(NSUInteger)encoderVersion;

@end
