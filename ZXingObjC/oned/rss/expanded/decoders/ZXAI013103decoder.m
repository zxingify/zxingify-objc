#import "ZXAI013103decoder.h"
#import "ZXBitArray.h"

@implementation ZXAI013103decoder

- (void) addWeightCode:(NSMutableString *)buf weight:(int)weight {
  [buf appendString:@"(3103)"];
}

- (int) checkWeight:(int)weight {
  return weight;
}

@end
