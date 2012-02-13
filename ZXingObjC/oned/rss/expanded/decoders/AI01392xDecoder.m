#import "AI01392xDecoder.h"
#import "BitArray.h"
#import "GeneralAppIdDecoder.h"
#import "NotFoundException.h"

int const headerSize = 5 + 1 + 2;
int const lastDigitSize = 2;

@implementation AI01392xDecoder

- (NSString *) parseInformation {
  if (information.size < headerSize + gtinSize) {
    @throw [NotFoundException notFoundInstance];
  }
  NSMutableString * buf = [NSMutableString string];
  [self encodeCompressedGtin:buf currentPos:headerSize];
  int lastAIdigit = [generalDecoder extractNumericValueFromBitArray:headerSize + gtinSize bits:lastDigitSize];
  [buf appendFormat:@"(392%d)", lastAIdigit];
  DecodedInformation * decodedInformation = [generalDecoder decodeGeneralPurposeField:headerSize + gtinSize + lastDigitSize remaining:nil];
  [buf append:decodedInformation.theNewString];
  return buf;
}

@end
