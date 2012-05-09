#import "ZXAI01AndOtherAIs.h"
#import "ZXGeneralAppIdDecoder.h"

int const AI01_HEADER_SIZE = 1 + 1 + 2;

@implementation ZXAI01AndOtherAIs

- (NSString *)parseInformation {
  NSMutableString * buff = [NSMutableString string];

  [buff appendString:@"(01)"];
  int initialGtinPosition = [buff length];
  int firstGtinDigit = [self.generalDecoder extractNumericValueFromBitArray:AI01_HEADER_SIZE bits:4];
  [buff appendFormat:@"%d", firstGtinDigit];

  [self encodeCompressedGtinWithoutAI:buff currentPos:AI01_HEADER_SIZE + 4 initialBufferPosition:initialGtinPosition];

  return [self.generalDecoder decodeAllCodes:buff initialPosition:AI01_HEADER_SIZE + 44];
}

@end
