#import "ZXAI01320xDecoder.h"

@implementation ZXAI01320xDecoder

- (void)addWeightCode:(NSMutableString *)buf weight:(int)weight {
  if (weight < 10000) {
    [buf appendString:@"(3202)"];
  } else {
    [buf appendString:@"(3203)"];
  }
}

- (int)checkWeight:(int)weight {
  if (weight < 10000) {
    return weight;
  }
  return weight - 10000;
}

@end
