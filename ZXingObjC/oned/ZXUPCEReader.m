#import "ZXBitArray.h"
#import "ZXNotFoundException.h"
#import "ZXUPCEReader.h"


/**
 * The pattern that marks the middle, and end, of a UPC-E pattern.
 * There is no "second half" to a UPC-E barcode.
 */
const int MIDDLE_END_PATTERN[6] = {1, 1, 1, 1, 1, 1};

/**
 * See {@link #L_AND_G_PATTERNS}; these values similarly represent patterns of
 * even-odd parity encodings of digits that imply both the number system (0 or 1)
 * used, and the check digit.
 */
const int NUMSYS_AND_CHECK_DIGIT_PATTERNS[2][10] = {
  {0x38, 0x34, 0x32, 0x31, 0x2C, 0x26, 0x23, 0x2A, 0x29, 0x25},
  {0x07, 0x0B, 0x0D, 0x0E, 0x13, 0x19, 0x1C, 0x15, 0x16, 0x1A}
};

@interface ZXUPCEReader ()

- (void) determineNumSysAndCheckDigit:(NSMutableString *)resultString lgPatternFound:(int)lgPatternFound;

@end

@implementation ZXUPCEReader

- (id) init {
  if (self = [super init]) {
    decodeMiddleCounters[0] = 0;
    decodeMiddleCounters[1] = 0;
    decodeMiddleCounters[2] = 0;
    decodeMiddleCounters[3] = 0;
  }
  return self;
}

- (int) decodeMiddle:(ZXBitArray *)row startRange:(NSArray *)startRange result:(NSMutableString *)result {
  const int countersLen = 4;
  int counters[countersLen] = {0, 0, 0, 0};
  int end = [row size];
  int rowOffset = [[startRange objectAtIndex:1] intValue];
  int lgPatternFound = 0;

  for (int x = 0; x < 6 && rowOffset < end; x++) {
    int bestMatch = [ZXUPCEANReader decodeDigit:row counters:counters countersLen:countersLen rowOffset:rowOffset patternType:UPC_EAN_PATTERNS_L_AND_G_PATTERNS];
    [result appendFormat:@"%C", (unichar)('0' + bestMatch % 10)];

    for (int i = 0; i < sizeof(counters) / sizeof(int); i++) {
      rowOffset += counters[i];
    }

    if (bestMatch >= 10) {
      lgPatternFound |= 1 << (5 - x);
    }
  }

  [self determineNumSysAndCheckDigit:result lgPatternFound:lgPatternFound];
  return rowOffset;
}

- (NSArray *) decodeEnd:(ZXBitArray *)row endStart:(int)endStart {
  return [ZXUPCEANReader findGuardPattern:row rowOffset:endStart whiteFirst:YES pattern:(int*)MIDDLE_END_PATTERN patternLen:sizeof(MIDDLE_END_PATTERN)/sizeof(int)];
}

- (BOOL) checkChecksum:(NSString *)s {
  return [super checkChecksum:[ZXUPCEReader convertUPCEtoUPCA:s]];
}

- (void) determineNumSysAndCheckDigit:(NSMutableString *)resultString lgPatternFound:(int)lgPatternFound {

  for (int numSys = 0; numSys <= 1; numSys++) {

    for (int d = 0; d < 10; d++) {
      if (lgPatternFound == NUMSYS_AND_CHECK_DIGIT_PATTERNS[numSys][d]) {
        [resultString insertString:[NSString stringWithFormat:@"%C", (unichar)'0' + numSys] atIndex:0];
        [resultString appendFormat:@"%C", (unichar)('0' + d)];
        return;
      }
    }

  }

  @throw [ZXNotFoundException notFoundInstance];
}

- (ZXBarcodeFormat) barcodeFormat {
  return kBarcodeFormatUPCE;
}


/**
 * Expands a UPC-E value back into its full, equivalent UPC-A code value.
 * 
 * @param upce UPC-E code as string of digits
 * @return equivalent UPC-A code as string of digits
 */
+ (NSString *) convertUPCEtoUPCA:(NSString *)upce {
  NSMutableString * result = [NSMutableString stringWithCapacity:12];
  [result appendFormat:@"%C", [upce characterAtIndex:0]];
  unichar lastChar = [upce characterAtIndex:[upce length] - 1];

  switch (lastChar) {
  case '0':
  case '1':
  case '2':
    [result appendString:[upce substringToIndex:2]];
    [result appendFormat:@"%C", lastChar];
    [result appendString:@"0000"];
    [result appendString:[upce substringWithRange:NSMakeRange(2, 3)]];
    break;
  case '3':
    [result appendString:[upce substringToIndex:3]];
    [result appendString:@"00000"];
    [result appendString:[upce substringWithRange:NSMakeRange(3, 2)]];
    break;
  case '4':
    [result appendString:[upce substringToIndex:4]];
    [result appendString:@"00000"];
    [result appendString:[upce substringWithRange:NSMakeRange(4, 1)]];
    break;
  default:
    [result appendString:[upce substringToIndex:5]];
    [result appendString:@"0000"];
    [result appendFormat:@"%C", lastChar];
    break;
  }
  [result appendFormat:@"%C", [upce characterAtIndex:7]];
  return result;
}

@end
