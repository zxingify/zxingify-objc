#import "ZXAI01392xDecoder.h"
#import "ZXBitArray.h"
#import "ZXDecodedInformation.h"
#import "ZXGeneralAppIdDecoder.h"
#import "ZXNotFoundException.h"

int const AI01392xHeaderSize = 5 + 1 + 2;
int const AI01392xLastDigitSize = 2;

@implementation ZXAI01392xDecoder

- (NSString *) parseInformation {
  if (information.size < AI01392xHeaderSize + gtinSize) {
    @throw [ZXNotFoundException notFoundInstance];
  }
  NSMutableString * buf = [NSMutableString string];
  [self encodeCompressedGtin:buf currentPos:AI01392xHeaderSize];
  int lastAIdigit = [generalDecoder extractNumericValueFromBitArray:AI01392xHeaderSize + gtinSize bits:AI01392xLastDigitSize];
  [buf appendFormat:@"(392%d)", lastAIdigit];
  ZXDecodedInformation * decodedInformation = [generalDecoder decodeGeneralPurposeField:AI01392xHeaderSize + gtinSize + AI01392xLastDigitSize remaining:nil];
  [buf appendString:decodedInformation.theNewString];
  return buf;
}

@end
