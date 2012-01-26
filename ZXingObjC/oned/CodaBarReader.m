#import "CodaBarReader.h"

NSString * const ALPHABET_STRING = @"0123456789-$:/.+ABCDTN";
NSArray * const ALPHABET = [ALPHABET_STRING toCharArray];

/**
 * These represent the encodings of characters, as patterns of wide and narrow bars. The 7 least-significant bits of
 * each int correspond to the pattern of wide and narrow, with 1s representing "wide" and 0s representing narrow. NOTE
 * : c is equal to the  * pattern NOTE : d is equal to the e pattern
 */
NSArray * const CHARACTER_ENCODINGS = [NSArray arrayWithObjects:0x003, 0x006, 0x009, 0x060, 0x012, 0x042, 0x021, 0x024, 0x030, 0x048, 0x00c, 0x018, 0x045, 0x051, 0x054, 0x015, 0x01A, 0x029, 0x00B, 0x00E, 0x01A, 0x029, nil];
int const minCharacterLength = 6;
NSArray * const STARTEND_ENCODING = [NSArray arrayWithObjects:'E', '*', 'A', 'B', 'C', 'D', 'T', 'N', nil];

@implementation CodaBarReader

- (Result *) decodeRow:(int)rowNumber row:(BitArray *)row hints:(NSMutableDictionary *)hints {
  NSArray * start = [self findAsteriskPattern:row];
  start[1] = 0;
  int nextStart = start[1];
  int end = [row size];

  while (nextStart < end && ![row get:nextStart]) {
    nextStart++;
  }

  StringBuffer * result = [[[StringBuffer alloc] init] autorelease];
  NSArray * counters;
  int lastStart;

  do {
    counters = [NSArray arrayWithObjects:0, 0, 0, 0, 0, 0, 0, nil];
    [self recordPattern:row param1:nextStart param2:counters];
    unichar decodedChar = [self toNarrowWidePattern:counters];
    if (decodedChar == '!') {
      @throw [NotFoundException notFoundInstance];
    }
    [result append:decodedChar];
    lastStart = nextStart;

    for (int i = 0; i < counters.length; i++) {
      nextStart += counters[i];
    }


    while (nextStart < end && ![row get:nextStart]) {
      nextStart++;
    }

  }
   while (nextStart < end);
  int lastPatternSize = 0;

  for (int i = 0; i < counters.length; i++) {
    lastPatternSize += counters[i];
  }

  int whiteSpaceAfterEnd = nextStart - lastStart - lastPatternSize;
  if (nextStart != end && (whiteSpaceAfterEnd / 2 < lastPatternSize)) {
    @throw [NotFoundException notFoundInstance];
  }
  if ([result length] < 2) {
    @throw [NotFoundException notFoundInstance];
  }
  unichar startchar = [result charAt:0];
  if (![self arrayContains:STARTEND_ENCODING key:startchar]) {
    @throw [NotFoundException notFoundInstance];
  }

  for (int k = 1; k < [result length]; k++) {
    if ([result charAt:k] == startchar) {
      if ((k + 1) != [result length]) {
        [result delete:k + 1 param1:[result length] - 1];
        k = [result length];
      }
    }
  }

  if ([result length] > minCharacterLength) {
    [result deleteCharAt:[result length] - 1];
    [result deleteCharAt:0];
  }
   else {
    @throw [NotFoundException notFoundInstance];
  }
  float left = (float)(start[1] + start[0]) / 2.0f;
  float right = (float)(nextStart + lastStart) / 2.0f;
  return [[[Result alloc] init:[result description] param1:nil param2:[NSArray arrayWithObjects:[[[ResultPoint alloc] init:left param1:(float)rowNumber] autorelease], [[[ResultPoint alloc] init:right param1:(float)rowNumber] autorelease], nil] param3:BarcodeFormat.CODABAR] autorelease];
}

+ (NSArray *) findAsteriskPattern:(BitArray *)row {
  int width = [row size];
  int rowOffset = 0;

  while (rowOffset < width) {
    if ([row get:rowOffset]) {
      break;
    }
    rowOffset++;
  }

  int counterPosition = 0;
  NSArray * counters = [NSArray array];
  int patternStart = rowOffset;
  BOOL isWhite = NO;
  int patternLength = counters.length;

  for (int i = rowOffset; i < width; i++) {
    BOOL pixel = [row get:i];
    if (pixel ^ isWhite) {
      counters[counterPosition]++;
    }
     else {
      if (counterPosition == patternLength - 1) {

        @try {
          if ([self arrayContains:STARTEND_ENCODING key:[self toNarrowWidePattern:counters]]) {
            if ([row isRange:[Math max:0 param1:patternStart - (i - patternStart) / 2] param1:patternStart param2:NO]) {
              return [NSArray arrayWithObjects:patternStart, i, nil];
            }
          }
        }
        @catch (IllegalArgumentException * re) {
        }
        patternStart += counters[0] + counters[1];

        for (int y = 2; y < patternLength; y++) {
          counters[y - 2] = counters[y];
        }

        counters[patternLength - 2] = 0;
        counters[patternLength - 1] = 0;
        counterPosition--;
      }
       else {
        counterPosition++;
      }
      counters[counterPosition] = 1;
      isWhite ^= YES;
    }
  }

  @throw [NotFoundException notFoundInstance];
}

+ (BOOL) arrayContains:(NSArray *)array key:(unichar)key {
  if (array != nil) {

    for (int i = 0; i < array.length; i++) {
      if (array[i] == key) {
        return YES;
      }
    }

  }
  return NO;
}

+ (unichar) toNarrowWidePattern:(NSArray *)counters {
  int numCounters = counters.length;
  int maxNarrowCounter = 0;
  int minCounter = Integer.MAX_VALUE;

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

      for (int i = 0; i < CHARACTER_ENCODINGS.length; i++) {
        if (CHARACTER_ENCODINGS[i] == pattern) {
          return ALPHABET[i];
        }
      }

    }
    maxNarrowCounter--;
  }
   while (maxNarrowCounter > minCounter);
  return '!';
}

@end
