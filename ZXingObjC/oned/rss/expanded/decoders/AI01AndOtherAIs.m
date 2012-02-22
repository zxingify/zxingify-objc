#import "AI01AndOtherAIs.h"
#import "GeneralAppIdDecoder.h"

int const AI01_HEADER_SIZE = 1 + 1 + 2;

@implementation AI01AndOtherAIs

- (NSString *) parseInformation {
  NSMutableString * buff = [NSMutableString string];

  [buff appendString:@"(01)"];
  int initialGtinPosition = [buff length];
  int firstGtinDigit = [generalDecoder extractNumericValueFromBitArray:AI01_HEADER_SIZE bits:4];
  [buff appendFormat:@"%d", firstGtinDigit];
  
  [self encodeCompressedGtinWithoutAI:buff currentPos:AI01_HEADER_SIZE + 4 initialBufferPosition:initialGtinPosition];

  return [generalDecoder decodeAllCodes:buff initialPosition:AI01_HEADER_SIZE + 44];
}

@end
