#import "ZXAI01393xDecoder.h"
#import "ZXBitArray.h"
#import "ZXDecodedInformation.h"
#import "ZXErrors.h"
#import "ZXGeneralAppIdDecoder.h"

@implementation ZXAI01393xDecoder

int const AI01393xDecoderHeaderSize = 5 + 1 + 2;
int const AI01393xDecoderLastDigitSize = 2;
int const AI01393xDecoderFirstThreeDigitsSize = 10;

- (NSString *)parseInformationWithError:(NSError **)error {
  if (self.information.size < AI01393xDecoderHeaderSize + gtinSize) {
    if (error) *error = NotFoundErrorInstance();
    return nil;
  }

  NSMutableString * buf = [NSMutableString string];

  [self encodeCompressedGtin:buf currentPos:AI01393xDecoderHeaderSize];

  int lastAIdigit = [self.generalDecoder extractNumericValueFromBitArray:AI01393xDecoderHeaderSize + gtinSize bits:AI01393xDecoderLastDigitSize];

  [buf appendFormat:@"(393%d)", lastAIdigit];

  int firstThreeDigits = [self.generalDecoder extractNumericValueFromBitArray:AI01393xDecoderHeaderSize + gtinSize + AI01393xDecoderLastDigitSize bits:AI01393xDecoderFirstThreeDigitsSize];
  if (firstThreeDigits / 100 == 0) {
    [buf appendString:@"0"];
  }
  if (firstThreeDigits / 10 == 0) {
    [buf appendString:@"0"];
  }
  [buf appendFormat:@"%d", firstThreeDigits];

  ZXDecodedInformation * generalInformation = [self.generalDecoder decodeGeneralPurposeField:AI01393xDecoderHeaderSize + gtinSize + AI01393xDecoderLastDigitSize + AI01393xDecoderFirstThreeDigitsSize remaining:nil];
  [buf appendString:generalInformation.theNewString];

  return buf;
}

@end
