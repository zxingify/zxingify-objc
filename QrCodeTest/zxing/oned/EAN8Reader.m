#import "EAN8Reader.h"

@implementation EAN8Reader

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

  for (int x = 0; x < 4 && rowOffset < end; x++) {
    int bestMatch = [self decodeDigit:row param1:counters param2:rowOffset param3:L_PATTERNS];
    [result append:(unichar)('0' + bestMatch)];

    for (int i = 0; i < counters.length; i++) {
      rowOffset += counters[i];
    }

  }

  NSArray * middleRange = [self findGuardPattern:row param1:rowOffset param2:YES param3:MIDDLE_PATTERN];
  rowOffset = middleRange[1];

  for (int x = 0; x < 4 && rowOffset < end; x++) {
    int bestMatch = [self decodeDigit:row param1:counters param2:rowOffset param3:L_PATTERNS];
    [result append:(unichar)('0' + bestMatch)];

    for (int i = 0; i < counters.length; i++) {
      rowOffset += counters[i];
    }

  }

  return rowOffset;
}

- (BarcodeFormat *) getBarcodeFormat {
  return BarcodeFormat.EAN_8;
}

- (void) dealloc {
  [decodeMiddleCounters release];
  [super dealloc];
}

@end
