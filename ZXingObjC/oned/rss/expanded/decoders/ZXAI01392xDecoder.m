#import "ZXAI01392xDecoder.h"
#import "ZXBitArray.h"
#import "ZXDecodedInformation.h"
#import "ZXErrors.h"
#import "ZXGeneralAppIdDecoder.h"

int const AI01392xHeaderSize = 5 + 1 + 2;
int const AI01392xLastDigitSize = 2;

@implementation ZXAI01392xDecoder

- (NSString *)parseInformationWithError:(NSError **)error {
  if (self.information.size < AI01392xHeaderSize + gtinSize) {
    if (error) *error = NotFoundErrorInstance();
    return nil;
  }
  NSMutableString * buf = [NSMutableString string];
  [self encodeCompressedGtin:buf currentPos:AI01392xHeaderSize];
  int lastAIdigit = [self.generalDecoder extractNumericValueFromBitArray:AI01392xHeaderSize + gtinSize bits:AI01392xLastDigitSize];
  [buf appendFormat:@"(392%d)", lastAIdigit];
  ZXDecodedInformation * decodedInformation = [self.generalDecoder decodeGeneralPurposeField:AI01392xHeaderSize + gtinSize + AI01392xLastDigitSize remaining:nil];
  [buf appendString:decodedInformation.theNewString];
  return buf;
}

@end
