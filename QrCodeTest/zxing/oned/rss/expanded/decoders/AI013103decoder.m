#import "AI013103decoder.h"

@implementation AI013103decoder

- (id) initWithInformation:(BitArray *)information {
  if (self = [super init:information]) {
  }
  return self;
}

- (void) addWeightCode:(StringBuffer *)buf weight:(int)weight {
  [buf append:@"(3103)"];
}

- (int) checkWeight:(int)weight {
  return weight;
}

@end
