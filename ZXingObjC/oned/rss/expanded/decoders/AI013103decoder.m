#import "AI013103decoder.h"
#import "BitArray.h"

@implementation AI013103decoder

- (void) addWeightCode:(NSMutableString *)buf weight:(int)weight {
  [buf appendString:@"(3103)"];
}

- (int) checkWeight:(int)weight {
  return weight;
}

@end
