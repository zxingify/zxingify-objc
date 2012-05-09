#import "ZXAbstractExpandedDecoder.h"

extern const int gtinSize;

@interface ZXAI01decoder : ZXAbstractExpandedDecoder

- (void)encodeCompressedGtin:(NSMutableString *)buf currentPos:(int)currentPos;
- (void)encodeCompressedGtinWithoutAI:(NSMutableString *)buf currentPos:(int)currentPos initialBufferPosition:(int)initialBufferPosition;

@end
