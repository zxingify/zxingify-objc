#import "ZXAI01decoder.h"

@class ZXBitArray;

@interface ZXAI01weightDecoder : ZXAI01decoder

- (void)encodeCompressedWeight:(NSMutableString *)buf currentPos:(int)currentPos weightSize:(int)weightSize;
- (void)addWeightCode:(NSMutableString *)buf weight:(int)weight;
- (int)checkWeight:(int)weight;

@end
