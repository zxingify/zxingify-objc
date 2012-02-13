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
- (unichar) toNarrowWidePattern:(NSArray *)counters;

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
  NSMutableArray * counters;
  int lastStart;

  do {
    counters = [NSMutableArray arrayWithObjects:[NSNumber numberWithInt:0], [NSNumber numberWithInt:0],
                [NSNumber numberWithInt:0], [NSNumber numberWithInt:0], [NSNumber numberWithInt:0],
                [NSNumber numberWithInt:0], [NSNumber numberWithInt:0], nil];
    [OneDReader recordPattern:row start:nextStart counters:counters];
    unichar decodedChar = [self toNarrowWidePattern:counters];
    if (decodedChar == '!') {
      @throw [NotFoundException notFoundInstance];
    }
    [result appendFormat:@"%c", decodedChar];
    lastStart = nextStart;

    for (NSNumber *i in counters) {
      nextStart += [i intValue];
    }

    while (nextStart < end && ![row get:nextStart]) {
      nextStart++;
    }
  } while (nextStart < end);

  int lastPatternSize = 0;
  for (NSNumber *i in counters) {
    lastPatternSize += [i intValue];
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
  return [[[Result alloc] init:result
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
  NSMutableArray * counters = [NSMutableArray arrayWithCapacity:7];
  for (int i = 0; i < 7; i++) {
    [counters addObject:[NSNumber numberWithInt:0]];
  }  
  int patternStart = rowOffset;
  BOOL isWhite = NO;
  int patternLength = [counters count];

  for (int i = rowOffset; i < width; i++) {
    BOOL pixel = [row get:i];
    if (pixel ^ isWhite) {
      [counters replaceObjectAtIndex:counterPosition
                          withObject:[NSNumber numberWithInt:[[counters objectAtIndex:counterPosition] intValue] + 1]];
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
        
        patternStart += [[counters objectAtIndex:0] intValue] + [[counters objectAtIndex:1] intValue];
        for (int y = 2; y < patternLength; y++) {
          [counters replaceObjectAtIndex:y - 2 withObject:[counters objectAtIndex:y]];
        }
        [counters replaceObjectAtIndex:patternLength - 2 withObject:[NSNumber numberWithInt:0]];
        [counters replaceObjectAtIndex:patternLength - 1 withObject:[NSNumber numberWithInt:0]];
        counterPosition--;
      } else {
        counterPosition++;
      }
      [counters replaceObjectAtIndex:counterPosition withObject:[NSNumber numberWithInt:1]];
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

- (unichar) toNarrowWidePattern:(NSArray *)counters {
  int numCounters = [counters count];
  int maxNarrowCounter = 0;
  
  int minCounter = NSIntegerMax;
  for (int i = 0; i < numCounters; i++) {
    if ([[counters objectAtIndex:i] intValue] < minCounter) {
      minCounter = [[counters objectAtIndex:i] intValue];
    }
    if ([[counters objectAtIndex:i] intValue] > maxNarrowCounter) {
      maxNarrowCounter = [[counters objectAtIndex:i] intValue];
    }
  }

  do {
    int wideCounters = 0;
    int pattern = 0;

    for (int i = 0; i < numCounters; i++) {
      if ([[counters objectAtIndex:i] intValue] > maxNarrowCounter) {
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
