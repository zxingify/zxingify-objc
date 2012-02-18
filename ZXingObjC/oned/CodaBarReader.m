#import "BitArray.h"
#import "CodaBarReader.h"
#import "NotFoundException.h"
#import "Result.h"
#import "ResultPoint.h"

const NSString *ALPHABET_STRING = @"0123456789-$:/.+ABCDTN";
const char ALPHABET[] = "0123456789-$:/.+ABCDTN";

/**
 * These represent the encodings of characters, as patterns of wide and narrow bars. The 7 least-significant bits of
 * each int correspond to the pattern of wide and narrow, with 1s representing "wide" and 0s representing narrow. NOTE
 * : c is equal to the  * pattern NOTE : d is equal to the e pattern
 */
const int CHARACTER_ENCODINGS[22] = {
  0x003, 0x006, 0x009, 0x060, 0x012, 0x042, 0x021, 0x024, 0x030, 0x048, // 0-9
  0x00c, 0x018, 0x045, 0x051, 0x054, 0x015, 0x01A, 0x029, 0x00B, 0x00E, // -$:/.+ABCD
  0x01A, 0x029 //TN
};

// minimal number of characters that should be present (inclusing start and stop characters)
// this check has been added to reduce the number of false positive on other formats
// until the cause for this behaviour has been determined
// under normal circumstances this should be set to 3
const int minCharacterLength = 6;

// multiple start/end patterns
// official start and end patterns
const char STARTEND_ENCODING[8] = {'E', '*', 'A', 'B', 'C', 'D', 'T', 'N'};

// some industries use a checksum standard but this is not part of the original codabar standard
// for more information see : http://www.mecsw.com/specs/codabar.html

@interface CodaBarReader ()

- (BOOL) arrayContains:(char *)array key:(unichar)key;
- (NSMutableArray *) findAsteriskPattern:(BitArray *)row;
- (unichar) toNarrowWidePattern:(int[])counters;

@end

@implementation CodaBarReader

- (Result *) decodeRow:(int)rowNumber row:(BitArray *)row hints:(NSMutableDictionary *)hints {
  NSMutableArray * start = [self findAsteriskPattern:row];
  [start replaceObjectAtIndex:1 withObject:[NSNumber numberWithInt:0]];
  int nextStart = [[start objectAtIndex:1] intValue];
  int end = [row size];

  while (nextStart < end && ![row get:nextStart]) {
    nextStart++;
  }

  NSMutableString * result = [NSMutableString string];
  int counters[7];
  int lastStart;

  do {
    for (int i = 0; i < 7; i++) {
      counters[i] = 0;
    }

    [OneDReader recordPattern:row start:nextStart counters:counters];

    unichar decodedChar = [self toNarrowWidePattern:counters];
    if (decodedChar == '!') {
      @throw [NotFoundException notFoundInstance];
    }
    [result appendFormat:@"%c", decodedChar];
    lastStart = nextStart;
    for (int i = 0; i < sizeof(counters) / sizeof(int); i++) {
      nextStart += counters[i];
    }

    while (nextStart < end && ![row get:nextStart]) {
      nextStart++;
    }
  } while (nextStart < end);

  int lastPatternSize = 0;
  for (int i = 0; i < sizeof(counters) / sizeof(int); i++) {
    lastPatternSize += counters[i];
  }

  int whiteSpaceAfterEnd = nextStart - lastStart - lastPatternSize;
  if (nextStart != end && (whiteSpaceAfterEnd / 2 < lastPatternSize)) {
    @throw [NotFoundException notFoundInstance];
  }
  if ([result length] < 2) {
    @throw [NotFoundException notFoundInstance];
  }
  unichar startchar = [result characterAtIndex:0];
  if (![self arrayContains:(char*)STARTEND_ENCODING key:startchar]) {
    @throw [NotFoundException notFoundInstance];
  }

  for (int k = 1; k < [result length]; k++) {
    if ([result characterAtIndex:k] == startchar) {
      if ((k + 1) != [result length]) {
        [result deleteCharactersInRange:NSMakeRange(k + 1, [result length] - k)];
        k = [result length];
      }
    }
  }

  if ([result length] > minCharacterLength) {
    [result deleteCharactersInRange:NSMakeRange([result length] - 1, 1)];
    [result deleteCharactersInRange:NSMakeRange(0, 1)];
  } else {
    @throw [NotFoundException notFoundInstance];
  }

  float left = (float)([[start objectAtIndex:1] intValue] + [[start objectAtIndex:0] intValue]) / 2.0f;
  float right = (float)(nextStart + lastStart) / 2.0f;
  return [[[Result alloc] initWithText:result
                              rawBytes:nil
                          resultPoints:[NSArray arrayWithObjects:
                                        [[[ResultPoint alloc] initWithX:left y:(float)rowNumber] autorelease],
                                        [[[ResultPoint alloc] initWithX:right y:(float)rowNumber] autorelease], nil]
                                format:kBarcodeFormatCodabar] autorelease];
}

- (NSMutableArray *) findAsteriskPattern:(BitArray *)row {
  int width = [row size];
  int rowOffset = 0;

  while (rowOffset < width) {
    if ([row get:rowOffset]) {
      break;
    }
    rowOffset++;
  }

  int counterPosition = 0;
  int counters[7];
  int patternStart = rowOffset;
  BOOL isWhite = NO;
  int patternLength = sizeof(counters) / sizeof(int);

  for (int i = rowOffset; i < width; i++) {
    BOOL pixel = [row get:i];
    if (pixel ^ isWhite) {
      counters[counterPosition]++;
    } else {
      if (counterPosition == patternLength - 1) {
        @try {
          if ([self arrayContains:(char*)STARTEND_ENCODING key:[self toNarrowWidePattern:counters]]) {
            if ([row isRange:MAX(0, patternStart - (i - patternStart) / 2) end:patternStart value:NO]) {
              return [NSArray arrayWithObjects:[NSNumber numberWithInt:patternStart],
                      [NSNumber numberWithInt:i], nil];
            }
          }
        }
        @catch (NSException * re) {
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
      isWhite ^= YES;
    }
  }

  @throw [NotFoundException notFoundInstance];
}

- (BOOL) arrayContains:(char *)array key:(unichar)key {
  if (array != nil) {
    for (int i = 0; i < sizeof(array) / sizeof(char); i++) {
      if (array[i] == key) {
        return YES;
      }
    }

  }
  return NO;
}

- (unichar) toNarrowWidePattern:(int[])counters {
  int numCounters = sizeof((int*)counters) / sizeof(int);
  int maxNarrowCounter = 0;
  
  int minCounter = NSIntegerMax;
  for (int i = 0; i < numCounters; i++) {
    if (counters[i] < minCounter) {
      minCounter = counters[i];
    }
    if (counters[i] > maxNarrowCounter) {
      maxNarrowCounter = counters[i];
    }
  }

  do {
    int wideCounters = 0;
    int pattern = 0;

    for (int i = 0; i < numCounters; i++) {
      if (counters[i] > maxNarrowCounter) {
        pattern |= 1 << (numCounters - 1 - i);
        wideCounters++;
      }
    }

    if ((wideCounters == 2) || (wideCounters == 3)) {
      for (int i = 0; i < sizeof(CHARACTER_ENCODINGS) / sizeof(int); i++) {
        if (CHARACTER_ENCODINGS[i] == pattern) {
          return ALPHABET[i];
        }
      }

    }
    maxNarrowCounter--;
  } while (maxNarrowCounter > minCounter);

  return '!';
}

@end
