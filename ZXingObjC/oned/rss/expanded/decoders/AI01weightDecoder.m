#import "AI01weightDecoder.h"

@implementation AI01weightDecoder

- (id) initWithInformation:(BitArray *)information {
  if (self = [super init:information]) {
  }
  return self;
}

- (void) encodeCompressedWeight:(StringBuffer *)buf currentPos:(int)currentPos weightSize:(int)weightSize {
  int originalWeightNumeric = [generalDecoder extractNumericValueFromBitArray:currentPos param1:weightSize];
  [self addWeightCode:buf weight:originalWeightNumeric];
  int weightNumeric = [self checkWeight:originalWeightNumeric];
  int currentDivisor = 100000;

  for (int i = 0; i < 5; ++i) {
    if (weightNumeric / currentDivisor == 0) {
      [buf append:'0'];
    }
    currentDivisor /= 10;
  }

  [buf append:weightNumeric];
}

- (void) addWeightCode:(StringBuffer *)buf weight:(int)weight {
}

- (int) checkWeight:(int)weight {
}

@end
