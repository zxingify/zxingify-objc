#import "ZXBitArray.h"
#import "ZXEAN8Reader.h"

@interface ZXEAN8Reader ()

@property (nonatomic, assign) int* decodeMiddleCounters;

@end

@implementation ZXEAN8Reader

@synthesize decodeMiddleCounters;

- (id)init {
  if (self = [super init]) {
    self.decodeMiddleCounters = (int*)malloc(sizeof(4) * sizeof(int));
    self.decodeMiddleCounters[0] = 0;
    self.decodeMiddleCounters[1] = 0;
    self.decodeMiddleCounters[2] = 0;
    self.decodeMiddleCounters[3] = 0;
  }

  return self;
}

- (void)dealloc {
  if (self.decodeMiddleCounters != NULL) {
    free(self.decodeMiddleCounters);
    self.decodeMiddleCounters = NULL;
  }

  [super dealloc];
}

- (int)decodeMiddle:(ZXBitArray *)row startRange:(NSArray *)startRange result:(NSMutableString *)result error:(NSError **)error {
  const int countersLen = 4;
  int counters[countersLen] = {0, 0, 0, 0};
  int end = row.size;
  int rowOffset = [[startRange objectAtIndex:1] intValue];

  for (int x = 0; x < 4 && rowOffset < end; x++) {
    int bestMatch = [ZXUPCEANReader decodeDigit:row counters:counters countersLen:countersLen rowOffset:rowOffset patternType:UPC_EAN_PATTERNS_L_PATTERNS error:error];
    if (bestMatch == -1) {
      return -1;
    }
    [result appendFormat:@"%C", (unichar)('0' + bestMatch)];
    for (int i = 0; i < countersLen; i++) {
      rowOffset += counters[i];
    }
  }

  NSArray * middleRange = [ZXUPCEANReader findGuardPattern:row rowOffset:rowOffset whiteFirst:YES pattern:(int*)MIDDLE_PATTERN patternLen:MIDDLE_PATTERN_LEN error:error];
  if (!middleRange) {
    return -1;
  }
  rowOffset = [[middleRange objectAtIndex:1] intValue];

  for (int x = 0; x < 4 && rowOffset < end; x++) {
    int bestMatch = [ZXUPCEANReader decodeDigit:row counters:counters countersLen:countersLen rowOffset:rowOffset patternType:UPC_EAN_PATTERNS_L_PATTERNS error:error];
    if (bestMatch == -1) {
      return -1;
    }
    [result appendFormat:@"%C", (unichar)('0' + bestMatch)];
    for (int i = 0; i < countersLen; i++) {
      rowOffset += counters[i];
    }
  }

  return rowOffset;
}

- (ZXBarcodeFormat)barcodeFormat {
  return kBarcodeFormatEan8;
}

@end
