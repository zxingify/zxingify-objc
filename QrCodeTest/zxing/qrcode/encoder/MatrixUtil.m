#import "MatrixUtil.h"

NSArray * const POSITION_DETECTION_PATTERN = [NSArray arrayWithObjects:[NSArray arrayWithObjects:1, 1, 1, 1, 1, 1, 1, nil], [NSArray arrayWithObjects:1, 0, 0, 0, 0, 0, 1, nil], [NSArray arrayWithObjects:1, 0, 1, 1, 1, 0, 1, nil], [NSArray arrayWithObjects:1, 0, 1, 1, 1, 0, 1, nil], [NSArray arrayWithObjects:1, 0, 1, 1, 1, 0, 1, nil], [NSArray arrayWithObjects:1, 0, 0, 0, 0, 0, 1, nil], [NSArray arrayWithObjects:1, 1, 1, 1, 1, 1, 1, nil], nil];
NSArray * const HORIZONTAL_SEPARATION_PATTERN = [NSArray arrayWithObjects:[NSArray arrayWithObjects:0, 0, 0, 0, 0, 0, 0, 0, nil], nil];
NSArray * const VERTICAL_SEPARATION_PATTERN = [NSArray arrayWithObjects:[NSArray arrayWithObjects:0, nil], [NSArray arrayWithObjects:0, nil], [NSArray arrayWithObjects:0, nil], [NSArray arrayWithObjects:0, nil], [NSArray arrayWithObjects:0, nil], [NSArray arrayWithObjects:0, nil], [NSArray arrayWithObjects:0, nil], nil];
NSArray * const POSITION_ADJUSTMENT_PATTERN = [NSArray arrayWithObjects:[NSArray arrayWithObjects:1, 1, 1, 1, 1, nil], [NSArray arrayWithObjects:1, 0, 0, 0, 1, nil], [NSArray arrayWithObjects:1, 0, 1, 0, 1, nil], [NSArray arrayWithObjects:1, 0, 0, 0, 1, nil], [NSArray arrayWithObjects:1, 1, 1, 1, 1, nil], nil];
NSArray * const POSITION_ADJUSTMENT_PATTERN_COORDINATE_TABLE = [NSArray arrayWithObjects:[NSArray arrayWithObjects:-1, -1, -1, -1, -1, -1, -1, nil], [NSArray arrayWithObjects:6, 18, -1, -1, -1, -1, -1, nil], [NSArray arrayWithObjects:6, 22, -1, -1, -1, -1, -1, nil], [NSArray arrayWithObjects:6, 26, -1, -1, -1, -1, -1, nil], [NSArray arrayWithObjects:6, 30, -1, -1, -1, -1, -1, nil], [NSArray arrayWithObjects:6, 34, -1, -1, -1, -1, -1, nil], [NSArray arrayWithObjects:6, 22, 38, -1, -1, -1, -1, nil], [NSArray arrayWithObjects:6, 24, 42, -1, -1, -1, -1, nil], [NSArray arrayWithObjects:6, 26, 46, -1, -1, -1, -1, nil], [NSArray arrayWithObjects:6, 28, 50, -1, -1, -1, -1, nil], [NSArray arrayWithObjects:6, 30, 54, -1, -1, -1, -1, nil], [NSArray arrayWithObjects:6, 32, 58, -1, -1, -1, -1, nil], [NSArray arrayWithObjects:6, 34, 62, -1, -1, -1, -1, nil], [NSArray arrayWithObjects:6, 26, 46, 66, -1, -1, -1, nil], [NSArray arrayWithObjects:6, 26, 48, 70, -1, -1, -1, nil], [NSArray arrayWithObjects:6, 26, 50, 74, -1, -1, -1, nil], [NSArray arrayWithObjects:6, 30, 54, 78, -1, -1, -1, nil], [NSArray arrayWithObjects:6, 30, 56, 82, -1, -1, -1, nil], [NSArray arrayWithObjects:6, 30, 58, 86, -1, -1, -1, nil], [NSArray arrayWithObjects:6, 34, 62, 90, -1, -1, -1, nil], [NSArray arrayWithObjects:6, 28, 50, 72, 94, -1, -1, nil], [NSArray arrayWithObjects:6, 26, 50, 74, 98, -1, -1, nil], [NSArray arrayWithObjects:6, 30, 54, 78, 102, -1, -1, nil], [NSArray arrayWithObjects:6, 28, 54, 80, 106, -1, -1, nil], [NSArray arrayWithObjects:6, 32, 58, 84, 110, -1, -1, nil], [NSArray arrayWithObjects:6, 30, 58, 86, 114, -1, -1, nil], [NSArray arrayWithObjects:6, 34, 62, 90, 118, -1, -1, nil], [NSArray arrayWithObjects:6, 26, 50, 74, 98, 122, -1, nil], [NSArray arrayWithObjects:6, 30, 54, 78, 102, 126, -1, nil], [NSArray arrayWithObjects:6, 26, 52, 78, 104, 130, -1, nil], [NSArray arrayWithObjects:6, 30, 56, 82, 108, 134, -1, nil], [NSArray arrayWithObjects:6, 34, 60, 86, 112, 138, -1, nil], [NSArray arrayWithObjects:6, 30, 58, 86, 114, 142, -1, nil], [NSArray arrayWithObjects:6, 34, 62, 90, 118, 146, -1, nil], [NSArray arrayWithObjects:6, 30, 54, 78, 102, 126, 150, nil], [NSArray arrayWithObjects:6, 24, 50, 76, 102, 128, 154, nil], [NSArray arrayWithObjects:6, 28, 54, 80, 106, 132, 158, nil], [NSArray arrayWithObjects:6, 32, 58, 84, 110, 136, 162, nil], [NSArray arrayWithObjects:6, 26, 54, 82, 110, 138, 166, nil], [NSArray arrayWithObjects:6, 30, 58, 86, 114, 142, 170, nil], nil];
NSArray * const TYPE_INFO_COORDINATES = [NSArray arrayWithObjects:[NSArray arrayWithObjects:8, 0, nil], [NSArray arrayWithObjects:8, 1, nil], [NSArray arrayWithObjects:8, 2, nil], [NSArray arrayWithObjects:8, 3, nil], [NSArray arrayWithObjects:8, 4, nil], [NSArray arrayWithObjects:8, 5, nil], [NSArray arrayWithObjects:8, 7, nil], [NSArray arrayWithObjects:8, 8, nil], [NSArray arrayWithObjects:7, 8, nil], [NSArray arrayWithObjects:5, 8, nil], [NSArray arrayWithObjects:4, 8, nil], [NSArray arrayWithObjects:3, 8, nil], [NSArray arrayWithObjects:2, 8, nil], [NSArray arrayWithObjects:1, 8, nil], [NSArray arrayWithObjects:0, 8, nil], nil];
int const VERSION_INFO_POLY = 0x1f25;
int const TYPE_INFO_POLY = 0x537;
int const TYPE_INFO_MASK_PATTERN = 0x5412;

@implementation MatrixUtil

- (id) init {
  if (self = [super init]) {
  }
  return self;
}

+ (void) clearMatrix:(ByteMatrix *)matrix {
  [matrix clear:(char)-1];
}

+ (void) buildMatrix:(BitArray *)dataBits ecLevel:(ErrorCorrectionLevel *)ecLevel version:(int)version maskPattern:(int)maskPattern matrix:(ByteMatrix *)matrix {
  [self clearMatrix:matrix];
  [self embedBasicPatterns:version matrix:matrix];
  [self embedTypeInfo:ecLevel maskPattern:maskPattern matrix:matrix];
  [self maybeEmbedVersionInfo:version matrix:matrix];
  [self embedDataBits:dataBits maskPattern:maskPattern matrix:matrix];
}

+ (void) embedBasicPatterns:(int)version matrix:(ByteMatrix *)matrix {
  [self embedPositionDetectionPatternsAndSeparators:matrix];
  [self embedDarkDotAtLeftBottomCorner:matrix];
  [self maybeEmbedPositionAdjustmentPatterns:version matrix:matrix];
  [self embedTimingPatterns:matrix];
}

+ (void) embedTypeInfo:(ErrorCorrectionLevel *)ecLevel maskPattern:(int)maskPattern matrix:(ByteMatrix *)matrix {
  BitArray * typeInfoBits = [[[BitArray alloc] init] autorelease];
  [self makeTypeInfoBits:ecLevel maskPattern:maskPattern bits:typeInfoBits];

  for (int i = 0; i < [typeInfoBits size]; ++i) {
    BOOL bit = [typeInfoBits get:[typeInfoBits size] - 1 - i];
    int x1 = TYPE_INFO_COORDINATES[i][0];
    int y1 = TYPE_INFO_COORDINATES[i][1];
    [matrix set:x1 param1:y1 param2:bit];
    if (i < 8) {
      int x2 = [matrix width] - i - 1;
      int y2 = 8;
      [matrix set:x2 param1:y2 param2:bit];
    }
     else {
      int x2 = 8;
      int y2 = [matrix height] - 7 + (i - 8);
      [matrix set:x2 param1:y2 param2:bit];
    }
  }

}

+ (void) maybeEmbedVersionInfo:(int)version matrix:(ByteMatrix *)matrix {
  if (version < 7) {
    return;
  }
  BitArray * versionInfoBits = [[[BitArray alloc] init] autorelease];
  [self makeVersionInfoBits:version bits:versionInfoBits];
  int bitIndex = 6 * 3 - 1;

  for (int i = 0; i < 6; ++i) {

    for (int j = 0; j < 3; ++j) {
      BOOL bit = [versionInfoBits get:bitIndex];
      bitIndex--;
      [matrix set:i param1:[matrix height] - 11 + j param2:bit];
      [matrix set:[matrix height] - 11 + j param1:i param2:bit];
    }

  }

}

+ (void) embedDataBits:(BitArray *)dataBits maskPattern:(int)maskPattern matrix:(ByteMatrix *)matrix {
  int bitIndex = 0;
  int direction = -1;
  int x = [matrix width] - 1;
  int y = [matrix height] - 1;

  while (x > 0) {
    if (x == 6) {
      x -= 1;
    }

    while (y >= 0 && y < [matrix height]) {

      for (int i = 0; i < 2; ++i) {
        int xx = x - i;
        if (![self isEmpty:[matrix get:xx param1:y]]) {
          continue;
        }
        BOOL bit;
        if (bitIndex < [dataBits size]) {
          bit = [dataBits get:bitIndex];
          ++bitIndex;
        }
         else {
          bit = NO;
        }
        if (maskPattern != -1) {
          if ([MaskUtil getDataMaskBit:maskPattern param1:xx param2:y]) {
            bit = !bit;
          }
        }
        [matrix set:xx param1:y param2:bit];
      }

      y += direction;
    }

    direction = -direction;
    y += direction;
    x -= 2;
  }

  if (bitIndex != [dataBits size]) {
    @throw [[[WriterException alloc] init:[@"Not all bits consumed: " stringByAppendingString:bitIndex] + '/' + [dataBits size]] autorelease];
  }
}

+ (int) findMSBSet:(int)value {
  int numDigits = 0;

  while (value != 0) {
    value >>>= 1;
    ++numDigits;
  }

  return numDigits;
}

+ (int) calculateBCHCode:(int)value poly:(int)poly {
  int msbSetInPoly = [self findMSBSet:poly];
  value <<= msbSetInPoly - 1;

  while ([self findMSBSet:value] >= msbSetInPoly) {
    value ^= poly << ([self findMSBSet:value] - msbSetInPoly);
  }

  return value;
}

+ (void) makeTypeInfoBits:(ErrorCorrectionLevel *)ecLevel maskPattern:(int)maskPattern bits:(BitArray *)bits {
  if (![QRCode isValidMaskPattern:maskPattern]) {
    @throw [[[WriterException alloc] init:@"Invalid mask pattern"] autorelease];
  }
  int typeInfo = ([ecLevel bits] << 3) | maskPattern;
  [bits appendBits:typeInfo param1:5];
  int bchCode = [self calculateBCHCode:typeInfo poly:TYPE_INFO_POLY];
  [bits appendBits:bchCode param1:10];
  BitArray * maskBits = [[[BitArray alloc] init] autorelease];
  [maskBits appendBits:TYPE_INFO_MASK_PATTERN param1:15];
  [bits xor:maskBits];
  if ([bits size] != 15) {
    @throw [[[WriterException alloc] init:[@"should not happen but we got: " stringByAppendingString:[bits size]]] autorelease];
  }
}

+ (void) makeVersionInfoBits:(int)version bits:(BitArray *)bits {
  [bits appendBits:version param1:6];
  int bchCode = [self calculateBCHCode:version poly:VERSION_INFO_POLY];
  [bits appendBits:bchCode param1:12];
  if ([bits size] != 18) {
    @throw [[[WriterException alloc] init:[@"should not happen but we got: " stringByAppendingString:[bits size]]] autorelease];
  }
}

+ (BOOL) isEmpty:(int)value {
  return value == -1;
}

+ (BOOL) isValidValue:(int)value {
  return value == -1 || value == 0 || value == 1;
}

+ (void) embedTimingPatterns:(ByteMatrix *)matrix {

  for (int i = 8; i < [matrix width] - 8; ++i) {
    int bit = (i + 1) % 2;
    if (![self isValidValue:[matrix get:i param1:6]]) {
      @throw [[[WriterException alloc] init] autorelease];
    }
    if ([self isEmpty:[matrix get:i param1:6]]) {
      [matrix set:i param1:6 param2:bit];
    }
    if (![self isValidValue:[matrix get:6 param1:i]]) {
      @throw [[[WriterException alloc] init] autorelease];
    }
    if ([self isEmpty:[matrix get:6 param1:i]]) {
      [matrix set:6 param1:i param2:bit];
    }
  }

}

+ (void) embedDarkDotAtLeftBottomCorner:(ByteMatrix *)matrix {
  if ([matrix get:8 param1:[matrix height] - 8] == 0) {
    @throw [[[WriterException alloc] init] autorelease];
  }
  [matrix set:8 param1:[matrix height] - 8 param2:1];
}

+ (void) embedHorizontalSeparationPattern:(int)xStart yStart:(int)yStart matrix:(ByteMatrix *)matrix {
  if (HORIZONTAL_SEPARATION_PATTERN[0].length != 8 || HORIZONTAL_SEPARATION_PATTERN.length != 1) {
    @throw [[[WriterException alloc] init:@"Bad horizontal separation pattern"] autorelease];
  }

  for (int x = 0; x < 8; ++x) {
    if (![self isEmpty:[matrix get:xStart + x param1:yStart]]) {
      @throw [[[WriterException alloc] init] autorelease];
    }
    [matrix set:xStart + x param1:yStart param2:HORIZONTAL_SEPARATION_PATTERN[0][x]];
  }

}

+ (void) embedVerticalSeparationPattern:(int)xStart yStart:(int)yStart matrix:(ByteMatrix *)matrix {
  if (VERTICAL_SEPARATION_PATTERN[0].length != 1 || VERTICAL_SEPARATION_PATTERN.length != 7) {
    @throw [[[WriterException alloc] init:@"Bad vertical separation pattern"] autorelease];
  }

  for (int y = 0; y < 7; ++y) {
    if (![self isEmpty:[matrix get:xStart param1:yStart + y]]) {
      @throw [[[WriterException alloc] init] autorelease];
    }
    [matrix set:xStart param1:yStart + y param2:VERTICAL_SEPARATION_PATTERN[y][0]];
  }

}

+ (void) embedPositionAdjustmentPattern:(int)xStart yStart:(int)yStart matrix:(ByteMatrix *)matrix {
  if (POSITION_ADJUSTMENT_PATTERN[0].length != 5 || POSITION_ADJUSTMENT_PATTERN.length != 5) {
    @throw [[[WriterException alloc] init:@"Bad position adjustment"] autorelease];
  }

  for (int y = 0; y < 5; ++y) {

    for (int x = 0; x < 5; ++x) {
      if (![self isEmpty:[matrix get:xStart + x param1:yStart + y]]) {
        @throw [[[WriterException alloc] init] autorelease];
      }
      [matrix set:xStart + x param1:yStart + y param2:POSITION_ADJUSTMENT_PATTERN[y][x]];
    }

  }

}

+ (void) embedPositionDetectionPattern:(int)xStart yStart:(int)yStart matrix:(ByteMatrix *)matrix {
  if (POSITION_DETECTION_PATTERN[0].length != 7 || POSITION_DETECTION_PATTERN.length != 7) {
    @throw [[[WriterException alloc] init:@"Bad position detection pattern"] autorelease];
  }

  for (int y = 0; y < 7; ++y) {

    for (int x = 0; x < 7; ++x) {
      if (![self isEmpty:[matrix get:xStart + x param1:yStart + y]]) {
        @throw [[[WriterException alloc] init] autorelease];
      }
      [matrix set:xStart + x param1:yStart + y param2:POSITION_DETECTION_PATTERN[y][x]];
    }

  }

}

+ (void) embedPositionDetectionPatternsAndSeparators:(ByteMatrix *)matrix {
  int pdpWidth = POSITION_DETECTION_PATTERN[0].length;
  [self embedPositionDetectionPattern:0 yStart:0 matrix:matrix];
  [self embedPositionDetectionPattern:[matrix width] - pdpWidth yStart:0 matrix:matrix];
  [self embedPositionDetectionPattern:0 yStart:[matrix width] - pdpWidth matrix:matrix];
  int hspWidth = HORIZONTAL_SEPARATION_PATTERN[0].length;
  [self embedHorizontalSeparationPattern:0 yStart:hspWidth - 1 matrix:matrix];
  [self embedHorizontalSeparationPattern:[matrix width] - hspWidth yStart:hspWidth - 1 matrix:matrix];
  [self embedHorizontalSeparationPattern:0 yStart:[matrix width] - hspWidth matrix:matrix];
  int vspSize = VERTICAL_SEPARATION_PATTERN.length;
  [self embedVerticalSeparationPattern:vspSize yStart:0 matrix:matrix];
  [self embedVerticalSeparationPattern:[matrix height] - vspSize - 1 yStart:0 matrix:matrix];
  [self embedVerticalSeparationPattern:vspSize yStart:[matrix height] - vspSize matrix:matrix];
}

+ (void) maybeEmbedPositionAdjustmentPatterns:(int)version matrix:(ByteMatrix *)matrix {
  if (version < 2) {
    return;
  }
  int index = version - 1;
  NSArray * coordinates = POSITION_ADJUSTMENT_PATTERN_COORDINATE_TABLE[index];
  int numCoordinates = POSITION_ADJUSTMENT_PATTERN_COORDINATE_TABLE[index].length;

  for (int i = 0; i < numCoordinates; ++i) {

    for (int j = 0; j < numCoordinates; ++j) {
      int y = coordinates[i];
      int x = coordinates[j];
      if (x == -1 || y == -1) {
        continue;
      }
      if ([self isEmpty:[matrix get:x param1:y]]) {
        [self embedPositionAdjustmentPattern:x - 2 yStart:y - 2 matrix:matrix];
      }
    }

  }

}

@end
