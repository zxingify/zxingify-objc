#import "AI01393xDecoder.h"
#import "BitArray.h"
#import "DecodedInformation.h"
#import "GeneralAppIdDecoder.h"
#import "NotFoundException.h"

@implementation AI01393xDecoder

int const AI01393xDecoderHeaderSize = 5 + 1 + 2;
int const AI01393xDecoderLastDigitSize = 2;
int const AI01393xDecoderFirstThreeDigitsSize = 10;

- (NSString *) parseInformation {
  if (information.size < AI01393xDecoderHeaderSize + gtinSize) {
    @throw [NotFoundException notFoundInstance];
  }

  NSMutableString * buf = [NSMutableString string];

  [self encodeCompressedGtin:buf currentPos:AI01393xDecoderHeaderSize];

  int lastAIdigit = [generalDecoder extractNumericValueFromBitArray:AI01393xDecoderHeaderSize + gtinSize bits:AI01393xDecoderLastDigitSize];

  [buf appendFormat:@"(393%d)", lastAIdigit];

  int firstThreeDigits = [generalDecoder extractNumericValueFromBitArray:AI01393xDecoderHeaderSize + gtinSize + AI01393xDecoderLastDigitSize bits:AI01393xDecoderFirstThreeDigitsSize];
  if (firstThreeDigits / 100 == 0) {
    [buf appendString:@"0"];
  }
  if (firstThreeDigits / 10 == 0) {
    [buf appendString:@"0"];
  }
  [buf appendFormat:@"%d", firstThreeDigits];

  DecodedInformation * generalInformation = [generalDecoder decodeGeneralPurposeField:AI01393xDecoderHeaderSize + gtinSize + AI01393xDecoderLastDigitSize + AI01393xDecoderFirstThreeDigitsSize remaining:nil];
  [buf appendString:generalInformation.theNewString];

  return buf;
}

@end
