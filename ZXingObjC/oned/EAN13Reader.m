#import "EAN13Reader.h"

#import "BarcodeFormat.h"
#import "NotFoundException.h"
#import "BitArray.h"

NSArray * const FIRST_DIGIT_ENCODINGS = [NSArray arrayWithObjects:0x00, 0x0B, 0x0D, 0xE, 0x13, 0x19, 0x1C, 0x15, 0x16, 0x1A, nil];

@implementation EAN13Reader

- (id) init {
  if (self = [super init]) {
    decodeMiddleCounters = [NSArray array];
  }
  return self;
}

- (int) decodeMiddle:(BitArray *)row startRange:(NSArray *)startRange resultString:(StringBuffer *)resultString {
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
    [resultString append:(unichar)('0' + bestMatch % 10)];

    for (int i = 0; i < counters.length; i++) {
      rowOffset += counters[i];
    }

    if (bestMatch >= 10) {
      lgPatternFound |= 1 << (5 - x);
    }
  }

  [self determineFirstDigit:resultString lgPatternFound:lgPatternFound];
  NSArray * middleRange = [self findGuardPattern:row param1:rowOffset param2:YES param3:MIDDLE_PATTERN];
  rowOffset = middleRange[1];

  for (int x = 0; x < 6 && rowOffset < end; x++) {
    int bestMatch = [self decodeDigit:row param1:counters param2:rowOffset param3:L_PATTERNS];
    [resultString append:(unichar)('0' + bestMatch)];

    for (int i = 0; i < counters.length; i++) {
      rowOffset += counters[i];
    }

  }

  return rowOffset;
}

- (BarcodeFormat *) getBarcodeFormat {
  return BarcodeFormat.EAN_13;
}


/**
 * Based on pattern of odd-even ('L' and 'G') patterns used to encoded the explicitly-encoded
 * digits in a barcode, determines the implicitly encoded first digit and adds it to the
 * result string.
 * 
 * @param resultString string to insert decoded first digit into
 * @param lgPatternFound int whose bits indicates the pattern of odd/even L/G patterns used to
 * encode digits
 * @throws NotFoundException if first digit cannot be determined
 */
+ (void) determineFirstDigit:(StringBuffer *)resultString lgPatternFound:(int)lgPatternFound {

  for (int d = 0; d < 10; d++) {
    if (lgPatternFound == FIRST_DIGIT_ENCODINGS[d]) {
      [resultString insert:0 param1:(unichar)('0' + d)];
      return;
    }
  }

  @throw [NotFoundException notFoundInstance];
}

- (void) dealloc {
  [decodeMiddleCounters release];
  [super dealloc];
}

@end
