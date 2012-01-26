#import "UPCEReader.h"


/**
 * The pattern that marks the middle, and end, of a UPC-E pattern.
 * There is no "second half" to a UPC-E barcode.
 */
NSArray * const MIDDLE_END_PATTERN = [NSArray arrayWithObjects:1, 1, 1, 1, 1, 1, nil];

/**
 * See {@link #L_AND_G_PATTERNS}; these values similarly represent patterns of
 * even-odd parity encodings of digits that imply both the number system (0 or 1)
 * used, and the check digit.
 */
NSArray * const NUMSYS_AND_CHECK_DIGIT_PATTERNS = [NSArray arrayWithObjects:[NSArray arrayWithObjects:0x38, 0x34, 0x32, 0x31, 0x2C, 0x26, 0x23, 0x2A, 0x29, 0x25, nil], [NSArray arrayWithObjects:0x07, 0x0B, 0x0D, 0x0E, 0x13, 0x19, 0x1C, 0x15, 0x16, 0x1A, nil], nil];

@implementation UPCEReader

- (id) init {
  if (self = [super init]) {
    decodeMiddleCounters = [NSArray array];
  }
  return self;
}

- (int) decodeMiddle:(BitArray *)row startRange:(NSArray *)startRange result:(StringBuffer *)result {
  NSArray * counters = decodeMiddleCounters;
  counters[0] = 0;
  counters[1] = 0;
  counters[2] = 0;
  counters[3] = 0;
  int end = [row size];
  int rowOffset = startRange[1];
  int lgPatternFound = 0;

  for (int x = 0; x < 6 && rowOffset < end; x++) {
    int bestMatch = [self decodeDigit:row param1:counters param2:rowOffset param3:L_AND_G_PATTERNS];
    [result append:(unichar)('0' + bestMatch % 10)];

    for (int i = 0; i < counters.length; i++) {
      rowOffset += counters[i];
    }

    if (bestMatch >= 10) {
      lgPatternFound |= 1 << (5 - x);
    }
  }

  [self determineNumSysAndCheckDigit:result lgPatternFound:lgPatternFound];
  return rowOffset;
}

- (NSArray *) decodeEnd:(BitArray *)row endStart:(int)endStart {
  return [self findGuardPattern:row param1:endStart param2:YES param3:MIDDLE_END_PATTERN];
}

- (BOOL) checkChecksum:(NSString *)s {
  return [super checkChecksum:[self convertUPCEtoUPCA:s]];
}

+ (void) determineNumSysAndCheckDigit:(StringBuffer *)resultString lgPatternFound:(int)lgPatternFound {

  for (int numSys = 0; numSys <= 1; numSys++) {

    for (int d = 0; d < 10; d++) {
      if (lgPatternFound == NUMSYS_AND_CHECK_DIGIT_PATTERNS[numSys][d]) {
        [resultString insert:0 param1:(unichar)('0' + numSys)];
        [resultString append:(unichar)('0' + d)];
        return;
      }
    }

  }

  @throw [NotFoundException notFoundInstance];
}

- (BarcodeFormat *) getBarcodeFormat {
  return BarcodeFormat.UPC_E;
}


/**
 * Expands a UPC-E value back into its full, equivalent UPC-A code value.
 * 
 * @param upce UPC-E code as string of digits
 * @return equivalent UPC-A code as string of digits
 */
+ (NSString *) convertUPCEtoUPCA:(NSString *)upce {
  NSArray * upceChars = [NSArray array];
  [upce getCharacters:1 param1:7 param2:upceChars param3:0];
  StringBuffer * result = [[[StringBuffer alloc] init:12] autorelease];
  [result append:[upce characterAtIndex:0]];
  unichar lastChar = upceChars[5];

  switch (lastChar) {
  case '0':
  case '1':
  case '2':
    [result append:upceChars param1:0 param2:2];
    [result append:lastChar];
    [result append:@"0000"];
    [result append:upceChars param1:2 param2:3];
    break;
  case '3':
    [result append:upceChars param1:0 param2:3];
    [result append:@"00000"];
    [result append:upceChars param1:3 param2:2];
    break;
  case '4':
    [result append:upceChars param1:0 param2:4];
    [result append:@"00000"];
    [result append:upceChars[4]];
    break;
  default:
    [result append:upceChars param1:0 param2:5];
    [result append:@"0000"];
    [result append:lastChar];
    break;
  }
  [result append:[upce characterAtIndex:7]];
  return [result description];
}

- (void) dealloc {
  [decodeMiddleCounters release];
  [super dealloc];
}

@end
