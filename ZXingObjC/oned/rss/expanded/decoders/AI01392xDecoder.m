#import "AI01392xDecoder.h"

int const headerSize = 5 + 1 + 2;
int const lastDigitSize = 2;

@implementation AI01392xDecoder

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
  [buf append:@"(392"];
  [buf append:lastAIdigit];
  [buf append:')'];
  DecodedInformation * decodedInformation = [generalDecoder decodeGeneralPurposeField:headerSize + gtinSize + lastDigitSize param1:nil];
  [buf append:[decodedInformation newString]];
  return [buf description];
}

@end
