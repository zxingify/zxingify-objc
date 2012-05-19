#import "ZXBitArray.h"
#import "ZXByteMatrix.h"
#import "ZXErrorCorrectionLevel.h"
#import "ZXMaskUtil.h"
#import "ZXMatrixUtil.h"
#import "ZXQRCode.h"
#import "ZXWriterException.h"

int const POSITION_DETECTION_PATTERN[7][7] = {
  {1, 1, 1, 1, 1, 1, 1},
  {1, 0, 0, 0, 0, 0, 1},
  {1, 0, 1, 1, 1, 0, 1},
  {1, 0, 1, 1, 1, 0, 1},
  {1, 0, 1, 1, 1, 0, 1},
  {1, 0, 0, 0, 0, 0, 1},
  {1, 1, 1, 1, 1, 1, 1},
};

int const HORIZONTAL_SEPARATION_PATTERN[1][8] = {
  {0, 0, 0, 0, 0, 0, 0, 0},
};

int const VERTICAL_SEPARATION_PATTERN[7][1] = {
  {0}, {0}, {0}, {0}, {0}, {0}, {0},
};

int const POSITION_ADJUSTMENT_PATTERN[5][5] = {
  {1, 1, 1, 1, 1},
  {1, 0, 0, 0, 1},
  {1, 0, 1, 0, 1},
  {1, 0, 0, 0, 1},
  {1, 1, 1, 1, 1},
};

// From Appendix E. Table 1, JIS0510X:2004 (p 71). The table was double-checked by komatsu.
int const POSITION_ADJUSTMENT_PATTERN_COORDINATE_TABLE[40][7] = {
  {-1, -1, -1, -1,  -1,  -1,  -1},  // Version 1
  { 6, 18, -1, -1,  -1,  -1,  -1},  // Version 2
  { 6, 22, -1, -1,  -1,  -1,  -1},  // Version 3
  { 6, 26, -1, -1,  -1,  -1,  -1},  // Version 4
  { 6, 30, -1, -1,  -1,  -1,  -1},  // Version 5
  { 6, 34, -1, -1,  -1,  -1,  -1},  // Version 6
  { 6, 22, 38, -1,  -1,  -1,  -1},  // Version 7
  { 6, 24, 42, -1,  -1,  -1,  -1},  // Version 8
  { 6, 26, 46, -1,  -1,  -1,  -1},  // Version 9
  { 6, 28, 50, -1,  -1,  -1,  -1},  // Version 10
  { 6, 30, 54, -1,  -1,  -1,  -1},  // Version 11
  { 6, 32, 58, -1,  -1,  -1,  -1},  // Version 12
  { 6, 34, 62, -1,  -1,  -1,  -1},  // Version 13
  { 6, 26, 46, 66,  -1,  -1,  -1},  // Version 14
  { 6, 26, 48, 70,  -1,  -1,  -1},  // Version 15
  { 6, 26, 50, 74,  -1,  -1,  -1},  // Version 16
  { 6, 30, 54, 78,  -1,  -1,  -1},  // Version 17
  { 6, 30, 56, 82,  -1,  -1,  -1},  // Version 18
  { 6, 30, 58, 86,  -1,  -1,  -1},  // Version 19
  { 6, 34, 62, 90,  -1,  -1,  -1},  // Version 20
  { 6, 28, 50, 72,  94,  -1,  -1},  // Version 21
  { 6, 26, 50, 74,  98,  -1,  -1},  // Version 22
  { 6, 30, 54, 78, 102,  -1,  -1},  // Version 23
  { 6, 28, 54, 80, 106,  -1,  -1},  // Version 24
  { 6, 32, 58, 84, 110,  -1,  -1},  // Version 25
  { 6, 30, 58, 86, 114,  -1,  -1},  // Version 26
  { 6, 34, 62, 90, 118,  -1,  -1},  // Version 27
  { 6, 26, 50, 74,  98, 122,  -1},  // Version 28
  { 6, 30, 54, 78, 102, 126,  -1},  // Version 29
  { 6, 26, 52, 78, 104, 130,  -1},  // Version 30
  { 6, 30, 56, 82, 108, 134,  -1},  // Version 31
  { 6, 34, 60, 86, 112, 138,  -1},  // Version 32
  { 6, 30, 58, 86, 114, 142,  -1},  // Version 33
  { 6, 34, 62, 90, 118, 146,  -1},  // Version 34
  { 6, 30, 54, 78, 102, 126, 150},  // Version 35
  { 6, 24, 50, 76, 102, 128, 154},  // Version 36
  { 6, 28, 54, 80, 106, 132, 158},  // Version 37
  { 6, 32, 58, 84, 110, 136, 162},  // Version 38
  { 6, 26, 54, 82, 110, 138, 166},  // Version 39
  { 6, 30, 58, 86, 114, 142, 170},  // Version 40
};

// Type info cells at the left top corner.
int const TYPE_INFO_COORDINATES[15][2] = {
  {8, 0},
  {8, 1},
  {8, 2},
  {8, 3},
  {8, 4},
  {8, 5},
  {8, 7},
  {8, 8},
  {7, 8},
  {5, 8},
  {4, 8},
  {3, 8},
  {2, 8},
  {1, 8},
  {0, 8},
};

// From Appendix D in JISX0510:2004 (p. 67)
int const VERSION_INFO_POLY = 0x1f25;  // 1 1111 0010 0101

// From Appendix C in JISX0510:2004 (p.65).
int const TYPE_INFO_POLY = 0x537;
int const TYPE_INFO_MASK_PATTERN = 0x5412;

@interface ZXMatrixUtil ()

+ (void)clearMatrix:(ZXByteMatrix *)matrix;
+ (BOOL)isEmpty:(int)value;
+ (BOOL)isValidValue:(int)value;
+ (void)embedTimingPatterns:(ZXByteMatrix *)matrix;
+ (void)embedDarkDotAtLeftBottomCorner:(ZXByteMatrix *)matrix;
+ (void)embedHorizontalSeparationPattern:(int)xStart yStart:(int)yStart matrix:(ZXByteMatrix *)matrix;
+ (void)embedVerticalSeparationPattern:(int)xStart yStart:(int)yStart matrix:(ZXByteMatrix *)matrix;
+ (void)embedPositionAdjustmentPattern:(int)xStart yStart:(int)yStart matrix:(ZXByteMatrix *)matrix;
+ (void)embedPositionDetectionPattern:(int)xStart yStart:(int)yStart matrix:(ZXByteMatrix *)matrix;
+ (void)embedPositionDetectionPatternsAndSeparators:(ZXByteMatrix *)matrix;
+ (void)maybeEmbedPositionAdjustmentPatterns:(int)version matrix:(ZXByteMatrix *)matrix;

@end

@implementation ZXMatrixUtil

// Set all cells to -1.  -1 means that the cell is empty (not set yet).
+ (void) clearMatrix:(ZXByteMatrix *)matrix {
  [matrix clear:(char) -1];
}

// Build 2D matrix of QR Code from "dataBits" with "ecLevel", "version" and "getMaskPattern". On
// success, store the result in "matrix" and return true.
+ (void)buildMatrix:(ZXBitArray *)dataBits ecLevel:(ZXErrorCorrectionLevel *)ecLevel version:(int)version maskPattern:(int)maskPattern matrix:(ZXByteMatrix *)matrix {
  [self clearMatrix:matrix];
  [self embedBasicPatterns:version matrix:matrix];
  [self embedTypeInfo:ecLevel maskPattern:maskPattern matrix:matrix];
  [self maybeEmbedVersionInfo:version matrix:matrix];
  [self embedDataBits:dataBits maskPattern:maskPattern matrix:matrix];
}

+ (void)embedBasicPatterns:(int)version matrix:(ZXByteMatrix *)matrix {
  [self embedPositionDetectionPatternsAndSeparators:matrix];
  [self embedDarkDotAtLeftBottomCorner:matrix];
  [self maybeEmbedPositionAdjustmentPatterns:version matrix:matrix];
  [self embedTimingPatterns:matrix];
}

+ (void)embedTypeInfo:(ZXErrorCorrectionLevel *)ecLevel maskPattern:(int)maskPattern matrix:(ZXByteMatrix *)matrix {
  ZXBitArray * typeInfoBits = [[[ZXBitArray alloc] init] autorelease];
  [self makeTypeInfoBits:ecLevel maskPattern:maskPattern bits:typeInfoBits];

  for (int i = 0; i < [typeInfoBits size]; ++i) {
    BOOL bit = [typeInfoBits get:[typeInfoBits size] - 1 - i];
    int x1 = TYPE_INFO_COORDINATES[i][0];
    int y1 = TYPE_INFO_COORDINATES[i][1];
    [matrix setX:x1 y:y1 boolValue:bit];
    if (i < 8) {
      int x2 = [matrix width] - i - 1;
      int y2 = 8;
      [matrix setX:x2 y:y2 boolValue:bit];
    } else {
      int x2 = 8;
      int y2 = [matrix height] - 7 + (i - 8);
      [matrix setX:x2 y:y2 boolValue:bit];
    }
  }
}

+ (void)maybeEmbedVersionInfo:(int)version matrix:(ZXByteMatrix *)matrix {
  if (version < 7) {
    return;
  }
  ZXBitArray * versionInfoBits = [[[ZXBitArray alloc] init] autorelease];
  [self makeVersionInfoBits:version bits:versionInfoBits];
  int bitIndex = 6 * 3 - 1;

  for (int i = 0; i < 6; ++i) {
    for (int j = 0; j < 3; ++j) {
      BOOL bit = [versionInfoBits get:bitIndex];
      bitIndex--;
      [matrix setX:i y:[matrix height] - 11 + j boolValue:bit];
      [matrix setX:[matrix height] - 11 + j y:i boolValue:bit];
    }
  }
}

+ (void)embedDataBits:(ZXBitArray *)dataBits maskPattern:(int)maskPattern matrix:(ZXByteMatrix *)matrix {
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
        if (![self isEmpty:[matrix getX:xx y:y]]) {
          continue;
        }
        BOOL bit;
        if (bitIndex < [dataBits size]) {
          bit = [dataBits get:bitIndex];
          ++bitIndex;
        } else {
          bit = NO;
        }
        if (maskPattern != -1) {
          if ([ZXMaskUtil dataMaskBit:maskPattern x:xx y:y]) {
            bit = !bit;
          }
        }
        [matrix setX:xx y:y boolValue:bit];
      }

      y += direction;
    }

    direction = -direction;
    y += direction;
    x -= 2;
  }

  if (bitIndex != [dataBits size]) {
    @throw [[[ZXWriterException alloc] initWithName:@"ZXWriterException"
                                             reason:[NSString stringWithFormat:@"Not all bits consumed: %d/%d", bitIndex, [dataBits size]]
                                           userInfo:nil] autorelease];
  }
}

+ (int)findMSBSet:(int)value {
  int numDigits = 0;
  while (value != 0) {
    value = (int)((unsigned int)value >> 1);
    ++numDigits;
  }
  return numDigits;
}

+ (int)calculateBCHCode:(int)value poly:(int)poly {
  int msbSetInPoly = [self findMSBSet:poly];
  value <<= msbSetInPoly - 1;

  while ([self findMSBSet:value] >= msbSetInPoly) {
    value ^= poly << ([self findMSBSet:value] - msbSetInPoly);
  }

  return value;
}

+ (void)makeTypeInfoBits:(ZXErrorCorrectionLevel *)ecLevel maskPattern:(int)maskPattern bits:(ZXBitArray *)bits {
  if (![ZXQRCode isValidMaskPattern:maskPattern]) {
    @throw [[[ZXWriterException alloc] initWithName:@"ZXWriterException"
                                             reason:@"Invalid mask pattern"
                                           userInfo:nil] autorelease];
  }
  int typeInfo = ([ecLevel bits] << 3) | maskPattern;
  [bits appendBits:typeInfo numBits:5];
  int bchCode = [self calculateBCHCode:typeInfo poly:TYPE_INFO_POLY];
  [bits appendBits:bchCode numBits:10];
  ZXBitArray * maskBits = [[[ZXBitArray alloc] init] autorelease];
  [maskBits appendBits:TYPE_INFO_MASK_PATTERN numBits:15];
  [bits xor:maskBits];
  if ([bits size] != 15) {
    @throw [[[ZXWriterException alloc] initWithName:@"ZXWriterException"
                                             reason:[NSString stringWithFormat:@"should not happen but we got: %d", [bits size]]
                                           userInfo:nil] autorelease];
  }
}

+ (void)makeVersionInfoBits:(int)version bits:(ZXBitArray *)bits {
  [bits appendBits:version numBits:6];
  int bchCode = [self calculateBCHCode:version poly:VERSION_INFO_POLY];
  [bits appendBits:bchCode numBits:12];
  if ([bits size] != 18) {
    @throw [[[ZXWriterException alloc] initWithName:@"ZXWriterException"
                                             reason:[NSString stringWithFormat:@"should not happen but we got: %d", [bits size]]
                                           userInfo:nil] autorelease];
  }
}

+ (BOOL)isEmpty:(int)value {
  return value == -1;
}

+ (BOOL)isValidValue:(int)value {
  return value == -1 || value == 0 || value == 1;
}

+ (void)embedTimingPatterns:(ZXByteMatrix *)matrix {
  for (int i = 8; i < [matrix width] - 8; ++i) {
    int bit = (i + 1) % 2;
    if (![self isValidValue:[matrix getX:i y:6]]) {
      @throw [[[ZXWriterException alloc] init] autorelease];
    }
    if ([self isEmpty:[matrix getX:i y:6]]) {
      [matrix setX:i y:6 boolValue:bit];
    }
    if (![self isValidValue:[matrix getX:6 y:i]]) {
      @throw [[[ZXWriterException alloc] init] autorelease];
    }
    if ([self isEmpty:[matrix getX:6 y:i]]) {
      [matrix setX:6 y:i boolValue:bit];
    }
  }
}

+ (void)embedDarkDotAtLeftBottomCorner:(ZXByteMatrix *)matrix {
  if ([matrix getX:8 y:matrix.height - 8] == 0) {
    @throw [[[ZXWriterException alloc] init] autorelease];
  }
  [matrix setX:8 y:matrix.height - 8 intValue:1];
}

+ (void)embedHorizontalSeparationPattern:(int)xStart yStart:(int)yStart matrix:(ZXByteMatrix *)matrix {
  for (int x = 0; x < 8; ++x) {
    if (![self isEmpty:[matrix getX:xStart + x y:yStart]]) {
      @throw [[[ZXWriterException alloc] init] autorelease];
    }
    [matrix setX:xStart + x y:yStart intValue:HORIZONTAL_SEPARATION_PATTERN[0][x]];
  }
}

+ (void)embedVerticalSeparationPattern:(int)xStart yStart:(int)yStart matrix:(ZXByteMatrix *)matrix {
  for (int y = 0; y < 7; ++y) {
    if (![self isEmpty:[matrix getX:xStart y:yStart + y]]) {
      @throw [[[ZXWriterException alloc] init] autorelease];
    }
    [matrix setX:xStart y:yStart + y intValue:VERTICAL_SEPARATION_PATTERN[y][0]];
  }
}

+ (void)embedPositionAdjustmentPattern:(int)xStart yStart:(int)yStart matrix:(ZXByteMatrix *)matrix {
  for (int y = 0; y < 5; ++y) {
    for (int x = 0; x < 5; ++x) {
      if (![self isEmpty:[matrix getX:xStart + x y:yStart + y]]) {
        @throw [[[ZXWriterException alloc] init] autorelease];
      }
      [matrix setX:xStart + x y:yStart + y intValue:POSITION_ADJUSTMENT_PATTERN[y][x]];
    }
  }
}

+ (void) embedPositionDetectionPattern:(int)xStart yStart:(int)yStart matrix:(ZXByteMatrix *)matrix {
  for (int y = 0; y < 7; ++y) {

    for (int x = 0; x < 7; ++x) {
      if (![self isEmpty:[matrix getX:xStart + x y:yStart + y]]) {
        @throw [[[ZXWriterException alloc] init] autorelease];
      }
      [matrix setX:xStart + x y:yStart + y intValue:POSITION_DETECTION_PATTERN[y][x]];
    }

  }

}

+ (void)embedPositionDetectionPatternsAndSeparators:(ZXByteMatrix *)matrix {
  int pdpWidth = sizeof(POSITION_DETECTION_PATTERN[0]) / sizeof(int);
  [self embedPositionDetectionPattern:0 yStart:0 matrix:matrix];
  [self embedPositionDetectionPattern:[matrix width] - pdpWidth yStart:0 matrix:matrix];
  [self embedPositionDetectionPattern:0 yStart:[matrix width] - pdpWidth matrix:matrix];
  int hspWidth = sizeof(HORIZONTAL_SEPARATION_PATTERN[0]) / sizeof(int);
  [self embedHorizontalSeparationPattern:0 yStart:hspWidth - 1 matrix:matrix];
  [self embedHorizontalSeparationPattern:[matrix width] - hspWidth yStart:hspWidth - 1 matrix:matrix];
  [self embedHorizontalSeparationPattern:0 yStart:[matrix width] - hspWidth matrix:matrix];
  int vspSize = sizeof(VERTICAL_SEPARATION_PATTERN) / sizeof(int*);
  [self embedVerticalSeparationPattern:vspSize yStart:0 matrix:matrix];
  [self embedVerticalSeparationPattern:[matrix height] - vspSize - 1 yStart:0 matrix:matrix];
  [self embedVerticalSeparationPattern:vspSize yStart:[matrix height] - vspSize matrix:matrix];
}

+ (void)maybeEmbedPositionAdjustmentPatterns:(int)version matrix:(ZXByteMatrix *)matrix {
  if (version < 2) {
    return;
  }
  int index = version - 1;
  int numCoordinates = sizeof(POSITION_ADJUSTMENT_PATTERN_COORDINATE_TABLE[index]) / sizeof(int);

  for (int i = 0; i < numCoordinates; ++i) {
    for (int j = 0; j < numCoordinates; ++j) {
      int y = POSITION_ADJUSTMENT_PATTERN_COORDINATE_TABLE[index][i];
      int x = POSITION_ADJUSTMENT_PATTERN_COORDINATE_TABLE[index][j];
      if (x == -1 || y == -1) {
        continue;
      }
      if ([self isEmpty:[matrix getX:x y:y]]) {
        [self embedPositionAdjustmentPattern:x - 2 yStart:y - 2 matrix:matrix];
      }
    }
  }
}

@end
