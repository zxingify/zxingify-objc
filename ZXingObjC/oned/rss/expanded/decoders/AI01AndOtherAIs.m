#import "AI01AndOtherAIs.h"

int const HEADER_SIZE = 1 + 1 + 2;

@implementation AI01AndOtherAIs

- (NSString *) parseInformation {
  NSMutableString * buff = [[[NSMutableString alloc] init] autorelease];
  [buff append:@"(01)"];
  int initialGtinPosition = [buff length];
  int firstGtinDigit = [generalDecoder extractNumericValueFromBitArray:HEADER_SIZE param1:4];
  [buff append:firstGtinDigit];
  [self encodeCompressedGtinWithoutAI:buff param1:HEADER_SIZE + 4 param2:initialGtinPosition];
  return [generalDecoder decodeAllCodes:buff param1:HEADER_SIZE + 44];
}

@end
