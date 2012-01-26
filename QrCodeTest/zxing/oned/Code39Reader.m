#import "Code39Reader.h"

NSString * const ALPHABET_STRING = @"0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ-. *$/+%";
NSArray * const ALPHABET = [ALPHABET_STRING toCharArray];

/**
 * These represent the encodings of characters, as patterns of wide and narrow bars.
 * The 9 least-significant bits of each int correspond to the pattern of wide and narrow,
 * with 1s representing "wide" and 0s representing narrow.
 */
NSArray * const CHARACTER_ENCODINGS = [NSArray arrayWithObjects:0x034, 0x121, 0x061, 0x160, 0x031, 0x130, 0x070, 0x025, 0x124, 0x064, 0x109, 0x049, 0x148, 0x019, 0x118, 0x058, 0x00D, 0x10C, 0x04C, 0x01C, 0x103, 0x043, 0x142, 0x013, 0x112, 0x052, 0x007, 0x106, 0x046, 0x016, 0x181, 0x0C1, 0x1C0, 0x091, 0x190, 0x0D0, 0x085, 0x184, 0x0C4, 0x094, 0x0A8, 0x0A2, 0x08A, 0x02A, nil];
int const ASTERISK_ENCODING = CHARACTER_ENCODINGS[39];

@implementation Code39Reader


/**
 * Creates a reader that assumes all encoded data is data, and does not treat the final
 * character as a check digit. It will not decoded "extended Code 39" sequences.
 */
- (id) init {
  if (self = [super init]) {
    usingCheckDigit = NO;
    extendedMode = NO;
  }
  return self;
}


/**
 * Creates a reader that can be configured to check the last character as a check digit.
 * It will not decoded "extended Code 39" sequences.
 * 
 * @param usingCheckDigit if true, treat the last data character as a check digit, not
 * data, and verify that the checksum passes.
 */
- (id) initWithUsingCheckDigit:(BOOL)usingCheckDigit {
  if (self = [super init]) {
    usingCheckDigit = usingCheckDigit;
    extendedMode = NO;
  }
  return self;
}


/**
 * Creates a reader that can be configured to check the last character as a check digit,
 * or optionally attempt to decode "extended Code 39" sequences that are used to encode
 * the full ASCII character set.
 * 
 * @param usingCheckDigit if true, treat the last data character as a check digit, not
 * data, and verify that the checksum passes.
 * @param extendedMode if true, will attempt to decode extended Code 39 sequences in the
 * text.
 */
- (id) init:(BOOL)usingCheckDigit extendedMode:(BOOL)extendedMode {
  if (self = [super init]) {
    usingCheckDigit = usingCheckDigit;
    extendedMode = extendedMode;
  }
  return self;
}

- (Result *) decodeRow:(int)rowNumber row:(BitArray *)row hints:(NSMutableDictionary *)hints {
  NSArray * start = [self findAsteriskPattern:row];
  int nextStart = start[1];
  int end = [row size];

  while (nextStart < end && ![row get:nextStart]) {
    nextStart++;
  }

  StringBuffer * result = [[[StringBuffer alloc] init:20] autorelease];
  NSArray * counters = [NSArray array];
  unichar decodedChar;
  int lastStart;

  do {
    [self recordPattern:row param1:nextStart param2:counters];
    int pattern = [self toNarrowWidePattern:counters];
    if (pattern < 0) {
      @throw [NotFoundException notFoundInstance];
    }
    decodedChar = [self patternToChar:pattern];
    [result append:decodedChar];
    lastStart = nextStart;

    for (int i = 0; i < counters.length; i++) {
      nextStart += counters[i];
    }


    while (nextStart < end && ![row get:nextStart]) {
      nextStart++;
    }

  }
   while (decodedChar != '*');
  [result deleteCharAt:[result length] - 1];
  int lastPatternSize = 0;

  for (int i = 0; i < counters.length; i++) {
    lastPatternSize += counters[i];
  }

  int whiteSpaceAfterEnd = nextStart - lastStart - lastPatternSize;
  if (nextStart != end && whiteSpaceAfterEnd / 2 < lastPatternSize) {
    @throw [NotFoundException notFoundInstance];
  }
  if (usingCheckDigit) {
    int max = [result length] - 1;
    int total = 0;

    for (int i = 0; i < max; i++) {
      total += [ALPHABET_STRING rangeOfString:[result charAt:i]];
    }

    if ([result charAt:max] != ALPHABET[total % 43]) {
      @throw [ChecksumException checksumInstance];
    }
    [result deleteCharAt:max];
  }
  if ([result length] == 0) {
    @throw [NotFoundException notFoundInstance];
  }
  NSString * resultString;
  if (extendedMode) {
    resultString = [self decodeExtended:result];
  }
   else {
    resultString = [result description];
  }
  float left = (float)(start[1] + start[0]) / 2.0f;
  float right = (float)(nextStart + lastStart) / 2.0f;
  return [[[Result alloc] init:resultString param1:nil param2:[NSArray arrayWithObjects:[[[ResultPoint alloc] init:left param1:(float)rowNumber] autorelease], [[[ResultPoint alloc] init:right param1:(float)rowNumber] autorelease], nil] param3:BarcodeFormat.CODE_39] autorelease];
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
        if ([self toNarrowWidePattern:counters] == ASTERISK_ENCODING) {
          if ([row isRange:[Math max:0 param1:patternStart - (i - patternStart) / 2] param1:patternStart param2:NO]) {
            return [NSArray arrayWithObjects:patternStart, i, nil];
          }
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
      isWhite = !isWhite;
    }
  }

  @throw [NotFoundException notFoundInstance];
}

+ (int) toNarrowWidePattern:(NSArray *)counters {
  int numCounters = counters.length;
  int maxNarrowCounter = 0;
  int wideCounters;

  do {
    int minCounter = Integer.MAX_VALUE;

    for (int i = 0; i < numCounters; i++) {
      int counter = counters[i];
      if (counter < minCounter && counter > maxNarrowCounter) {
        minCounter = counter;
      }
    }

    maxNarrowCounter = minCounter;
    wideCounters = 0;
    int totalWideCountersWidth = 0;
    int pattern = 0;

    for (int i = 0; i < numCounters; i++) {
      int counter = counters[i];
      if (counters[i] > maxNarrowCounter) {
        pattern |= 1 << (numCounters - 1 - i);
        wideCounters++;
        totalWideCountersWidth += counter;
      }
    }

    if (wideCounters == 3) {

      for (int i = 0; i < numCounters && wideCounters > 0; i++) {
        int counter = counters[i];
        if (counters[i] > maxNarrowCounter) {
          wideCounters--;
          if ((counter << 1) >= totalWideCountersWidth) {
            return -1;
          }
        }
      }

      return pattern;
    }
  }
   while (wideCounters > 3);
  return -1;
}

+ (unichar) patternToChar:(int)pattern {

  for (int i = 0; i < CHARACTER_ENCODINGS.length; i++) {
    if (CHARACTER_ENCODINGS[i] == pattern) {
      return ALPHABET[i];
    }
  }

  @throw [NotFoundException notFoundInstance];
}

+ (NSString *) decodeExtended:(StringBuffer *)encoded {
  int length = [encoded length];
  StringBuffer * decoded = [[[StringBuffer alloc] init:length] autorelease];

  for (int i = 0; i < length; i++) {
    unichar c = [encoded charAt:i];
    if (c == '+' || c == '$' || c == '%' || c == '/') {
      unichar next = [encoded charAt:i + 1];
      unichar decodedChar = '\0';

      switch (c) {
      case '+':
        if (next >= 'A' && next <= 'Z') {
          decodedChar = (unichar)(next + 32);
        }
         else {
          @throw [FormatException formatInstance];
        }
        break;
      case '$':
        if (next >= 'A' && next <= 'Z') {
          decodedChar = (unichar)(next - 64);
        }
         else {
          @throw [FormatException formatInstance];
        }
        break;
      case '%':
        if (next >= 'A' && next <= 'E') {
          decodedChar = (unichar)(next - 38);
        }
         else if (next >= 'F' && next <= 'W') {
          decodedChar = (unichar)(next - 11);
        }
         else {
          @throw [FormatException formatInstance];
        }
        break;
      case '/':
        if (next >= 'A' && next <= 'O') {
          decodedChar = (unichar)(next - 32);
        }
         else if (next == 'Z') {
          decodedChar = ':';
        }
         else {
          @throw [FormatException formatInstance];
        }
        break;
      }
      [decoded append:decodedChar];
      i++;
    }
     else {
      [decoded append:c];
    }
  }

  return [decoded description];
}

@end
