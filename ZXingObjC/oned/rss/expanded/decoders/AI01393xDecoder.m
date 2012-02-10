#import "AI01393xDecoder.h"

int const headerSize = 5 + 1 + 2;
int const lastDigitSize = 2;
int const firstThreeDigitsSize = 10;

@implementation AI01393xDecoder

- (id) initWithInformation:(BitArray *)information {
  if (self = [super init:information]) {
  }
  return self;
}

- (NSString *) parseInformation {
  if (information.size < headerSize + gtinSize) {
    @throw [NotFoundException notFoundInstance];
  }
  NSMutableString * buf = [[[NSMutableString alloc] init] autorelease];
  [self encodeCompressedGtin:buf param1:headerSize];
  int lastAIdigit = [generalDecoder extractNumericValueFromBitArray:headerSize + gtinSize param1:lastDigitSize];
  [buf append:@"(393"];
  [buf append:lastAIdigit];
  [buf append:')'];
  int firstThreeDigits = [generalDecoder extractNumericValueFromBitArray:headerSize + gtinSize + lastDigitSize param1:firstThreeDigitsSize];
  if (firstThreeDigits / 100 == 0) {
    [buf append:'0'];
  }
  if (firstThreeDigits / 10 == 0) {
    [buf append:'0'];
  }
  [buf append:firstThreeDigits];
  DecodedInformation * generalInformation = [generalDecoder decodeGeneralPurposeField:headerSize + gtinSize + lastDigitSize + firstThreeDigitsSize param1:nil];
  [buf append:[generalInformation newString]];
  return [buf description];
}

@end
