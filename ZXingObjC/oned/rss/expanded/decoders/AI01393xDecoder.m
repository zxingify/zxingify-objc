#import "AI01393xDecoder.h"
#import "BitArray.h"
#import "DecodedInformation.h"
#import "GeneralAppIdDecoder.h"
#import "NotFoundException.h"

int const headerSize = 5 + 1 + 2;
int const lastDigitSize = 2;
int const firstThreeDigitsSize = 10;

@implementation AI01393xDecoder

- (NSString *) parseInformation {
  if (information.size < headerSize + gtinSize) {
    @throw [NotFoundException notFoundInstance];
  }

  NSMutableString * buf = [NSMutableString string];

  [self encodeCompressedGtin:buf currentPos:headerSize];

  int lastAIdigit = [generalDecoder extractNumericValueFromBitArray:headerSize + gtinSize bits:lastDigitSize];

  [buf appendFormat:@"(393%d)", lastAIdigit];

  int firstThreeDigits = [generalDecoder extractNumericValueFromBitArray:headerSize + gtinSize + lastDigitSize bits:firstThreeDigitsSize];
  if (firstThreeDigits / 100 == 0) {
    [buf appendString:@"0"];
  }
  if (firstThreeDigits / 10 == 0) {
    [buf appendString:@"0"];
  }
  [buf appendFormat:@"%d", firstThreeDigits];

  DecodedInformation * generalInformation = [generalDecoder decodeGeneralPurposeField:headerSize + gtinSize + lastDigitSize + firstThreeDigitsSize remaining:nil];
  [buf appendString:generalInformation.theNewString];

  return buf;
}

@end
