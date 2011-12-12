#import "UINibDecoder.h"


@interface UINibDecoderForKeyedArchive : UINibDecoder {
    NSData* _data;
}

- (id) initWithData:(NSData*)data;

@end
