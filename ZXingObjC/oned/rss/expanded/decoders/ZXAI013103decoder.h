#import "ZXAI013x0xDecoder.h"

@interface ZXAI013103decoder : ZXAI013x0xDecoder

- (void)addWeightCode:(NSMutableString *)buf weight:(int)weight;
- (int)checkWeight:(int)weight;

@end
