#import "ZXEAN8Reader.h"

@implementation ZXEAN8Reader

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

  for (int x = 0; x < 4 && rowOffset < end; x++) {
    int bestMatch = [ZXUPCEANReader decodeDigit:row counters:counters countersLen:countersLen rowOffset:rowOffset patternType:UPC_EAN_PATTERNS_L_PATTERNS];
    [result appendFormat:@"%C", (unichar)('0' + bestMatch)];
    for (int i = 0; i < sizeof(counters) / sizeof(int); i++) {
      rowOffset += counters[i];
    }
  }

  NSArray * middleRange = [ZXUPCEANReader findGuardPattern:row rowOffset:rowOffset whiteFirst:YES pattern:(int*)MIDDLE_PATTERN patternLen:MIDDLE_PATTERN_LEN];
  rowOffset = [[middleRange objectAtIndex:1] intValue];

  for (int x = 0; x < 4 && rowOffset < end; x++) {
    int bestMatch = [ZXUPCEANReader decodeDigit:row counters:counters countersLen:countersLen rowOffset:rowOffset patternType:UPC_EAN_PATTERNS_L_PATTERNS];
    [result appendFormat:@"%C", (unichar)('0' + bestMatch)];
    for (int i = 0; i < sizeof(counters) / sizeof(int); i++) {
      rowOffset += counters[i];
    }
  }

  return rowOffset;
}

- (ZXBarcodeFormat) barcodeFormat {
  return kBarcodeFormatEan8;
}

@end
