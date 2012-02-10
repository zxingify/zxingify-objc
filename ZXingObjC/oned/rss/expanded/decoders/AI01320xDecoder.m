#import "AI01320xDecoder.h"

@implementation AI01320xDecoder

- (id) initWithInformation:(BitArray *)information {
  if (self = [super init:information]) {
  }
  return self;
}

- (void) addWeightCode:(NSMutableString *)buf weight:(int)weight {
  if (weight < 10000) {
    [buf append:@"(3202)"];
  }
   else {
    [buf append:@"(3203)"];
  }
}

- (int) checkWeight:(int)weight {
  if (weight < 10000) {
    return weight;
  }
  return weight - 10000;
}

@end
