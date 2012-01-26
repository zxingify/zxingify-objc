#import "MaskUtil.h"

@interface MaskUtil

+ (int) applyMaskPenaltyRule1Internal:(ByteMatrix *)matrix isHorizontal:(BOOL)isHorizontal;

@end

@implementation MaskUtil

- (id) init {
  if (self = [super init]) {
  }
  return self;
}

+ (int) applyMaskPenaltyRule1:(ByteMatrix *)matrix {
  return [self applyMaskPenaltyRule1Internal:matrix isHorizontal:YES] + [self applyMaskPenaltyRule1Internal:matrix isHorizontal:NO];
}

+ (int) applyMaskPenaltyRule2:(ByteMatrix *)matrix {
  int penalty = 0;
  NSArray * array = [matrix array];
  int width = [matrix width];
  int height = [matrix height];

  for (int y = 0; y < height - 1; ++y) {

    for (int x = 0; x < width - 1; ++x) {
      int value = array[y][x];
      if (value == array[y][x + 1] && value == array[y + 1][x] && value == array[y + 1][x + 1]) {
        penalty += 3;
      }
    }

  }

  return penalty;
}

+ (int) applyMaskPenaltyRule3:(ByteMatrix *)matrix {
  int penalty = 0;
  NSArray * array = [matrix array];
  int width = [matrix width];
  int height = [matrix height];

  for (int y = 0; y < height; ++y) {

    for (int x = 0; x < width; ++x) {
      if (x + 6 < width && array[y][x] == 1 && array[y][x + 1] == 0 && array[y][x + 2] == 1 && array[y][x + 3] == 1 && array[y][x + 4] == 1 && array[y][x + 5] == 0 && array[y][x + 6] == 1 && ((x + 10 < width && array[y][x + 7] == 0 && array[y][x + 8] == 0 && array[y][x + 9] == 0 && array[y][x + 10] == 0) || (x - 4 >= 0 && array[y][x - 1] == 0 && array[y][x - 2] == 0 && array[y][x - 3] == 0 && array[y][x - 4] == 0))) {
        penalty += 40;
      }
      if (y + 6 < height && array[y][x] == 1 && array[y + 1][x] == 0 && array[y + 2][x] == 1 && array[y + 3][x] == 1 && array[y + 4][x] == 1 && array[y + 5][x] == 0 && array[y + 6][x] == 1 && ((y + 10 < height && array[y + 7][x] == 0 && array[y + 8][x] == 0 && array[y + 9][x] == 0 && array[y + 10][x] == 0) || (y - 4 >= 0 && array[y - 1][x] == 0 && array[y - 2][x] == 0 && array[y - 3][x] == 0 && array[y - 4][x] == 0))) {
        penalty += 40;
      }
    }

  }

  return penalty;
}

+ (int) applyMaskPenaltyRule4:(ByteMatrix *)matrix {
  int numDarkCells = 0;
  NSArray * array = [matrix array];
  int width = [matrix width];
  int height = [matrix height];

  for (int y = 0; y < height; ++y) {

    for (int x = 0; x < width; ++x) {
      if (array[y][x] == 1) {
        numDarkCells += 1;
      }
    }

  }

  int numTotalCells = [matrix height] * [matrix width];
  double darkRatio = (double)numDarkCells / numTotalCells;
  return [Math abs:(int)(darkRatio * 100 - 50)] / 5 * 10;
}

+ (BOOL) getDataMaskBit:(int)maskPattern x:(int)x y:(int)y {
  if (![QRCode isValidMaskPattern:maskPattern]) {
    @throw [[[IllegalArgumentException alloc] init:@"Invalid mask pattern"] autorelease];
  }
  int intermediate;
  int temp;

  switch (maskPattern) {
  case 0:
    intermediate = (y + x) & 0x1;
    break;
  case 1:
    intermediate = y & 0x1;
    break;
  case 2:
    intermediate = x % 3;
    break;
  case 3:
    intermediate = (y + x) % 3;
    break;
  case 4:
    intermediate = ((y >>> 1) + (x / 3)) & 0x1;
    break;
  case 5:
    temp = y * x;
    intermediate = (temp & 0x1) + (temp % 3);
    break;
  case 6:
    temp = y * x;
    intermediate = ((temp & 0x1) + (temp % 3)) & 0x1;
    break;
  case 7:
    temp = y * x;
    intermediate = ((temp % 3) + ((y + x) & 0x1)) & 0x1;
    break;
  default:
    @throw [[[IllegalArgumentException alloc] init:[@"Invalid mask pattern: " stringByAppendingString:maskPattern]] autorelease];
  }
  return intermediate == 0;
}

+ (int) applyMaskPenaltyRule1Internal:(ByteMatrix *)matrix isHorizontal:(BOOL)isHorizontal {
  int penalty = 0;
  int numSameBitCells = 0;
  int prevBit = -1;
  int iLimit = isHorizontal ? [matrix height] : [matrix width];
  int jLimit = isHorizontal ? [matrix width] : [matrix height];
  NSArray * array = [matrix array];

  for (int i = 0; i < iLimit; ++i) {

    for (int j = 0; j < jLimit; ++j) {
      int bit = isHorizontal ? array[i][j] : array[j][i];
      if (bit == prevBit) {
        numSameBitCells += 1;
        if (numSameBitCells == 5) {
          penalty += 3;
        }
         else if (numSameBitCells > 5) {
          penalty += 1;
        }
      }
       else {
        numSameBitCells = 1;
        prevBit = bit;
      }
    }

    numSameBitCells = 0;
  }

  return penalty;
}

@end
