#import "ZXBitArray.h"
#import "ZXChecksumException.h"
#import "ZXCode128Reader.h"
#import "ZXFormatException.h"
#import "ZXNotFoundException.h"
#import "ZXOneDReader.h"
#import "ZXResult.h"
#import "ZXResultPoint.h"

static const int CODE_PATTERNS_LENGTH = 107;
static const int countersLength = 7;

const int CODE_PATTERNS[CODE_PATTERNS_LENGTH][countersLength] = {
  {2, 1, 2, 2, 2, 2}, // 0
  {2, 2, 2, 1, 2, 2},
  {2, 2, 2, 2, 2, 1},
  {1, 2, 1, 2, 2, 3},
  {1, 2, 1, 3, 2, 2},
  {1, 3, 1, 2, 2, 2}, // 5
  {1, 2, 2, 2, 1, 3},
  {1, 2, 2, 3, 1, 2},
  {1, 3, 2, 2, 1, 2},
  {2, 2, 1, 2, 1, 3},
  {2, 2, 1, 3, 1, 2}, // 10
  {2, 3, 1, 2, 1, 2},
  {1, 1, 2, 2, 3, 2},
  {1, 2, 2, 1, 3, 2},
  {1, 2, 2, 2, 3, 1},
  {1, 1, 3, 2, 2, 2}, // 15
  {1, 2, 3, 1, 2, 2},
  {1, 2, 3, 2, 2, 1},
  {2, 2, 3, 2, 1, 1},
  {2, 2, 1, 1, 3, 2},
  {2, 2, 1, 2, 3, 1}, // 20
  {2, 1, 3, 2, 1, 2},
  {2, 2, 3, 1, 1, 2},
  {3, 1, 2, 1, 3, 1},
  {3, 1, 1, 2, 2, 2},
  {3, 2, 1, 1, 2, 2}, // 25
  {3, 2, 1, 2, 2, 1},
  {3, 1, 2, 2, 1, 2},
  {3, 2, 2, 1, 1, 2},
  {3, 2, 2, 2, 1, 1},
  {2, 1, 2, 1, 2, 3}, // 30
  {2, 1, 2, 3, 2, 1},
  {2, 3, 2, 1, 2, 1},
  {1, 1, 1, 3, 2, 3},
  {1, 3, 1, 1, 2, 3},
  {1, 3, 1, 3, 2, 1}, // 35
  {1, 1, 2, 3, 1, 3},
  {1, 3, 2, 1, 1, 3},
  {1, 3, 2, 3, 1, 1},
  {2, 1, 1, 3, 1, 3},
  {2, 3, 1, 1, 1, 3}, // 40
  {2, 3, 1, 3, 1, 1},
  {1, 1, 2, 1, 3, 3},
  {1, 1, 2, 3, 3, 1},
  {1, 3, 2, 1, 3, 1},
  {1, 1, 3, 1, 2, 3}, // 45
  {1, 1, 3, 3, 2, 1},
  {1, 3, 3, 1, 2, 1},
  {3, 1, 3, 1, 2, 1},
  {2, 1, 1, 3, 3, 1},
  {2, 3, 1, 1, 3, 1}, // 50
  {2, 1, 3, 1, 1, 3},
  {2, 1, 3, 3, 1, 1},
  {2, 1, 3, 1, 3, 1},
  {3, 1, 1, 1, 2, 3},
  {3, 1, 1, 3, 2, 1}, // 55
  {3, 3, 1, 1, 2, 1},
  {3, 1, 2, 1, 1, 3},
  {3, 1, 2, 3, 1, 1},
  {3, 3, 2, 1, 1, 1},
  {3, 1, 4, 1, 1, 1}, // 60
  {2, 2, 1, 4, 1, 1},
  {4, 3, 1, 1, 1, 1},
  {1, 1, 1, 2, 2, 4},
  {1, 1, 1, 4, 2, 2},
  {1, 2, 1, 1, 2, 4}, // 65
  {1, 2, 1, 4, 2, 1},
  {1, 4, 1, 1, 2, 2},
  {1, 4, 1, 2, 2, 1},
  {1, 1, 2, 2, 1, 4},
  {1, 1, 2, 4, 1, 2}, // 70
  {1, 2, 2, 1, 1, 4},
  {1, 2, 2, 4, 1, 1},
  {1, 4, 2, 1, 1, 2},
  {1, 4, 2, 2, 1, 1},
  {2, 4, 1, 2, 1, 1}, // 75
  {2, 2, 1, 1, 1, 4},
  {4, 1, 3, 1, 1, 1},
  {2, 4, 1, 1, 1, 2},
  {1, 3, 4, 1, 1, 1},
  {1, 1, 1, 2, 4, 2}, // 80
  {1, 2, 1, 1, 4, 2},
  {1, 2, 1, 2, 4, 1},
  {1, 1, 4, 2, 1, 2},
  {1, 2, 4, 1, 1, 2},
  {1, 2, 4, 2, 1, 1}, // 85
  {4, 1, 1, 2, 1, 2},
  {4, 2, 1, 1, 1, 2},
  {4, 2, 1, 2, 1, 1},
  {2, 1, 2, 1, 4, 1},
  {2, 1, 4, 1, 2, 1}, // 90
  {4, 1, 2, 1, 2, 1},
  {1, 1, 1, 1, 4, 3},
  {1, 1, 1, 3, 4, 1},
  {1, 3, 1, 1, 4, 1},
  {1, 1, 4, 1, 1, 3}, // 95
  {1, 1, 4, 3, 1, 1},
  {4, 1, 1, 1, 1, 3},
  {4, 1, 1, 3, 1, 1},
  {1, 1, 3, 1, 4, 1},
  {1, 1, 4, 1, 3, 1}, // 100
  {3, 1, 1, 1, 4, 1},
  {4, 1, 1, 1, 3, 1},
  {2, 1, 1, 4, 1, 2},
  {2, 1, 1, 2, 1, 4},
  {2, 1, 1, 2, 3, 2}, // 105
  {2, 3, 3, 1, 1, 1}
};


#define MAX_AVG_VARIANCE (int)(PATTERN_MATCH_RESULT_SCALE_FACTOR * 0.25f)
#define MAX_INDIVIDUAL_VARIANCE (int)(PATTERN_MATCH_RESULT_SCALE_FACTOR * 0.7f)

int const CODE_SHIFT = 98;
int const CODE_CODE_C = 99;
int const CODE_CODE_B = 100;
int const CODE_CODE_A = 101;
int const CODE_FNC_1 = 102;
int const CODE_FNC_2 = 97;
int const CODE_FNC_3 = 96;
int const CODE_FNC_4_A = 101;
int const CODE_FNC_4_B = 100;
int const CODE_START_A = 103;
int const CODE_START_B = 104;
int const CODE_START_C = 105;
int const CODE_STOP = 106;

@interface ZXCode128Reader ()

- (int) decodeCode:(ZXBitArray *)row counters:(int[])counters countersCount:(int)countersCount rowOffset:(int)rowOffset;
- (NSArray *) findStartPattern:(ZXBitArray *)row;

@end

@implementation ZXCode128Reader

- (NSArray *) findStartPattern:(ZXBitArray *)row {
  int width = [row size];
  int rowOffset = 0;
  while (rowOffset < width) {
    if ([row get:rowOffset]) {
      break;
    }
    rowOffset++;
  }

  int counterPosition = 0;
  int counters[6] = {0, 0, 0, 0, 0, 0};
  int patternStart = rowOffset;
  BOOL isWhite = NO;
  int patternLength = sizeof(counters) / sizeof(int);

  for (int i = rowOffset; i < width; i++) {
    BOOL pixel = [row get:i];
    if (pixel ^ isWhite) {
      counters[counterPosition]++;
    } else {
      if (counterPosition == patternLength - 1) {
        int bestVariance = MAX_AVG_VARIANCE;
        int bestMatch = -1;
        for (int startCode = CODE_START_A; startCode <= CODE_START_C; startCode++) {
          int variance = [ZXOneDReader patternMatchVariance:counters countersSize:sizeof(counters) / sizeof(int) pattern:(int*)CODE_PATTERNS[startCode] maxIndividualVariance:MAX_INDIVIDUAL_VARIANCE];
          if (variance < bestVariance) {
            bestVariance = variance;
            bestMatch = startCode;
          }
        }
        if (bestMatch >= 0) {
          if ([row isRange:MAX(0, patternStart - (i - patternStart) / 2) end:patternStart value:NO]) {
            return [NSArray arrayWithObjects:[NSNumber numberWithInt:patternStart], [NSNumber numberWithInt:i], [NSNumber numberWithInt:bestMatch], nil];
          }
        }
        patternStart += counters[0] + counters[1];
        for (int y = 2; y < patternLength; y++) {
          counters[y - 2] = counters[y];
        }
        counters[patternLength - 2] = 0;
        counters[patternLength - 1] = 0;
        counterPosition--;
      } else {
        counterPosition++;
      }
      counters[counterPosition] = 1;
      isWhite = !isWhite;
    }
  }

  @throw [ZXNotFoundException notFoundInstance];
}

- (int) decodeCode:(ZXBitArray *)row counters:(int[])counters countersCount:(int)countersCount rowOffset:(int)rowOffset {
  [ZXOneDReader recordPattern:row start:rowOffset counters:counters countersSize:countersCount];
  int bestVariance = MAX_AVG_VARIANCE;
  int bestMatch = -1;

  for (int d = 0; d < CODE_PATTERNS_LENGTH; d++) {
    int * pattern = (int*)CODE_PATTERNS[d];
    int variance = [ZXOneDReader patternMatchVariance:counters countersSize:countersCount pattern:pattern maxIndividualVariance:MAX_INDIVIDUAL_VARIANCE];
    if (variance < bestVariance) {
      bestVariance = variance;
      bestMatch = d;
    }
  }

  if (bestMatch >= 0) {
    return bestMatch;
  } else {
    @throw [ZXNotFoundException notFoundInstance];
  }
}

- (ZXResult *) decodeRow:(int)rowNumber row:(ZXBitArray *)row hints:(ZXDecodeHints *)hints {
  NSArray * startPatternInfo = [self findStartPattern:row];
  int startCode = [[startPatternInfo objectAtIndex:2] intValue];
  int codeSet;

  switch (startCode) {
  case CODE_START_A:
    codeSet = CODE_CODE_A;
    break;
  case CODE_START_B:
    codeSet = CODE_CODE_B;
    break;
  case CODE_START_C:
    codeSet = CODE_CODE_C;
    break;
  default:
    @throw [ZXFormatException formatInstance];
  }

  BOOL done = NO;
  BOOL isNextShifted = NO;

  NSMutableString *result = [NSMutableString stringWithCapacity:20];
  int lastStart = [[startPatternInfo objectAtIndex:0] intValue];
  int nextStart = [[startPatternInfo objectAtIndex:1] intValue];
  const int countersLen = 6;
  int counters[countersLen] = {0,0,0,0,0,0};

  int lastCode = 0;
  int code = 0;
  int checksumTotal = startCode;
  int multiplier = 0;
  BOOL lastCharacterWasPrintable = YES;

  while (!done) {
    BOOL unshift = isNextShifted;
    isNextShifted = NO;

    lastCode = code;

    code = [self decodeCode:row counters:counters countersCount:countersLen rowOffset:nextStart];

    if (code != CODE_STOP) {
      lastCharacterWasPrintable = YES;
    }

    if (code != CODE_STOP) {
      multiplier++;
      checksumTotal += multiplier * code;
    }

    lastStart = nextStart;
    for (int i = 0; i < sizeof(counters) / sizeof(int); i++) {
      nextStart += counters[i];
    }

    switch (code) {
    case CODE_START_A:
    case CODE_START_B:
    case CODE_START_C:
      @throw [ZXFormatException formatInstance];
    }

    switch (codeSet) {
    case CODE_CODE_A:
      if (code < 64) {
        [result appendFormat:@" %C", (unichar)code];
      } else if (code < 96) {
        [result appendFormat:@"%C", (unichar)(code - 64)];
      } else {
        if (code != CODE_STOP) {
          lastCharacterWasPrintable = NO;
        }

        switch (code) {
        case CODE_FNC_1:
        case CODE_FNC_2:
        case CODE_FNC_3:
        case CODE_FNC_4_A:
          break;
        case CODE_SHIFT:
          isNextShifted = YES;
          codeSet = CODE_CODE_B;
          break;
        case CODE_CODE_B:
          codeSet = CODE_CODE_B;
          break;
        case CODE_CODE_C:
          codeSet = CODE_CODE_C;
          break;
        case CODE_STOP:
          done = YES;
          break;
        }
      }
      break;
    case CODE_CODE_B:
      if (code < 96) {
        [result appendFormat:@" %C", (unichar)code];
      } else {
        if (code != CODE_STOP) {
          lastCharacterWasPrintable = NO;
        }

        switch (code) {
        case CODE_FNC_1:
        case CODE_FNC_2:
        case CODE_FNC_3:
        case CODE_FNC_4_B:
          break;
        case CODE_SHIFT:
          isNextShifted = YES;
          codeSet = CODE_CODE_A;
          break;
        case CODE_CODE_A:
          codeSet = CODE_CODE_A;
          break;
        case CODE_CODE_C:
          codeSet = CODE_CODE_C;
          break;
        case CODE_STOP:
          done = YES;
          break;
        }
      }
      break;
    case CODE_CODE_C:
      if (code < 100) {
        if (code < 10) {
          [result appendString:@"0"];
        }
        [result appendFormat:@"%C", (unichar)code];
      }
       else {
        if (code != CODE_STOP) {
          lastCharacterWasPrintable = NO;
        }

        switch (code) {
        case CODE_FNC_1:
          break;
        case CODE_CODE_A:
          codeSet = CODE_CODE_A;
          break;
        case CODE_CODE_B:
          codeSet = CODE_CODE_B;
          break;
        case CODE_STOP:
          done = YES;
          break;
        }
      }
      break;
    }
    if (unshift) {
      codeSet = codeSet == CODE_CODE_A ? CODE_CODE_B : CODE_CODE_A;
    }
  }

  int width = [row size];

  while (nextStart < width && [row get:nextStart]) {
    nextStart++;
  }

  int end = nextStart + (nextStart - lastStart) / 2;
  if (end > width) {
    end = width;
  }
  if (![row isRange:nextStart end:end value:NO]) {
    @throw [ZXNotFoundException notFoundInstance];
  }
  checksumTotal -= multiplier * lastCode;
  if (checksumTotal % 103 != lastCode) {
    @throw [ZXChecksumException checksumInstance];
  }
  int resultLength = [result length];
  if (resultLength > 0 && lastCharacterWasPrintable) {
    if (codeSet == CODE_CODE_C) {
      [result deleteCharactersInRange:NSMakeRange(resultLength - 2, 2)];
    } else {
      [result deleteCharactersInRange:NSMakeRange(resultLength - 1, 1)];
    }
  }
  NSString * resultString = [result description];
  if ([resultString length] == 0) {
    @throw [ZXFormatException formatInstance];
  }
  float left = (float)([[startPatternInfo objectAtIndex:1] intValue] + [[startPatternInfo objectAtIndex:0] intValue]) / 2.0f;
  float right = (float)(nextStart + lastStart) / 2.0f;
  return [[[ZXResult alloc] initWithText:resultString
                              rawBytes:nil
                                length:0
                          resultPoints:[NSArray arrayWithObjects:[[[ZXResultPoint alloc] initWithX:left y:(float)rowNumber] autorelease],
                                        [[[ZXResultPoint alloc] initWithX:right y:(float)rowNumber] autorelease], nil]
                                format:kBarcodeFormatCode128] autorelease];
}

@end
