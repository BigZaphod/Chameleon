#import "UINibDecoder.h"

@class UINibArchiveDataV1;
@interface UINibDecoderForNibArchiveV1 : UINibDecoder {
    UINibArchiveDataV1* archiveData_;
}

- (id) initWithData:(NSData*)data encoderVersion:(NSUInteger)encoderVersion;

@end
