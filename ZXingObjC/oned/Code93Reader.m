#import "Code93Reader.h"

NSString * const ALPHABET_STRING = @"0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ-. $/+%abcd*";
NSArray * const ALPHABET = [ALPHABET_STRING toCharArray];

/**
 * These represent the encodings of characters, as patterns of wide and narrow bars.
 * The 9 least-significant bits of each int correspond to the pattern of wide and narrow.
 */
NSArray * const CHARACTER_ENCODINGS = [NSArray arrayWithObjects:0x114, 0x148, 0x144, 0x142, 0x128, 0x124, 0x122, 0x150, 0x112, 0x10A, 0x1A8, 0x1A4, 0x1A2, 0x194, 0x192, 0x18A, 0x168, 0x164, 0x162, 0x134, 0x11A, 0x158, 0x14C, 0x146, 0x12C, 0x116, 0x1B4, 0x1B2, 0x1AC, 0x1A6, 0x196, 0x19A, 0x16C, 0x166, 0x136, 0x13A, 0x12E, 0x1D4, 0x1D2, 0x1CA, 0x16E, 0x176, 0x1AE, 0x126, 0x1DA, 0x1D6, 0x132, 0x15E, nil];
int const ASTERISK_ENCODING = CHARACTER_ENCODINGS[47];

@implementation Code93Reader

- (Result *) decodeRow:(int)rowNumber row:(BitArray *)row hints:(NSMutableDictionary *)hints {
  NSArray * start = [self findAsteriskPattern:row];
  int nextStart = start[1];
  int end = [row size];

  while (nextStart < end && ![row get:nextStart]) {
    nextStart++;
  }

  NSMutableString * result = [[[NSMutableString alloc] init:20] autorelease];
  NSArray * counters = [NSArray array];
  unichar decodedChar;
  int lastStart;

  do {
    [self recordPattern:row param1:nextStart param2:counters];
    int pattern = [self toPattern:counters];
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
  if (nextStart == end || ![row get:nextStart]) {
    @throw [NotFoundException notFoundInstance];
  }
  if ([result length] < 2) {
    @throw [NotFoundException notFoundInstance];
  }
  [self checkChecksums:result];
  [result setLength:[result length] - 2];
  NSString * resultString = [self decodeExtended:result];
  float left = (float)(start[1] + start[0]) / 2.0f;
  float right = (float)(nextStart + lastStart) / 2.0f;
  return [[[Result alloc] init:resultString param1:nil param2:[NSArray arrayWithObjects:[[[ResultPoint alloc] init:left param1:(float)rowNumber] autorelease], [[[ResultPoint alloc] init:right param1:(float)rowNumber] autorelease], nil] param3:BarcodeFormat.CODE_93] autorelease];
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
        if ([self toPattern:counters] == ASTERISK_ENCODING) {
          return [NSArray arrayWithObjects:patternStart, i, nil];
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

+ (int) toPattern:(NSArray *)counters {
  int max = counters.length;
  int sum = 0;

  for (int i = 0; i < max; i++) {
    sum += counters[i];
  }

  int pattern = 0;

  for (int i = 0; i < max; i++) {
    int scaledShifted = (counters[i] << INTEGER_MATH_SHIFT) * 9 / sum;
    int scaledUnshifted = scaledShifted >> INTEGER_MATH_SHIFT;
    if ((scaledShifted & 0xFF) > 0x7F) {
      scaledUnshifted++;
    }
    if (scaledUnshifted < 1 || scaledUnshifted > 4) {
      return -1;
    }
    if ((i & 0x01) == 0) {

      for (int j = 0; j < scaledUnshifted; j++) {
        pattern = (pattern << 1) | 0x01;
      }

    }
     else {
      pattern <<= scaledUnshifted;
    }
  }

  return pattern;
}

+ (unichar) patternToChar:(int)pattern {

  for (int i = 0; i < CHARACTER_ENCODINGS.length; i++) {
    if (CHARACTER_ENCODINGS[i] == pattern) {
      return ALPHABET[i];
    }
  }

  @throw [NotFoundException notFoundInstance];
}

+ (NSString *) decodeExtended:(NSMutableString *)encoded {
  int length = [encoded length];
  NSMutableString * decoded = [[[NSMutableString alloc] init:length] autorelease];

  for (int i = 0; i < length; i++) {
    unichar c = [encoded charAt:i];
    if (c >= 'a' && c <= 'd') {
      unichar next = [encoded charAt:i + 1];
      unichar decodedChar = '\0';

      switch (c) {
      case 'd':
        if (next >= 'A' && next <= 'Z') {
          decodedChar = (unichar)(next + 32);
        }
         else {
          @throw [FormatException formatInstance];
        }
        break;
      case 'a':
        if (next >= 'A' && next <= 'Z') {
          decodedChar = (unichar)(next - 64);
        }
         else {
          @throw [FormatException formatInstance];
        }
        break;
      case 'b':
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
      case 'c':
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

+ (void) checkChecksums:(NSMutableString *)result {
  int length = [result length];
  [self checkOneChecksum:result checkPosition:length - 2 weightMax:20];
  [self checkOneChecksum:result checkPosition:length - 1 weightMax:15];
}

+ (void) checkOneChecksum:(NSMutableString *)result checkPosition:(int)checkPosition weightMax:(int)weightMax {
  int weight = 1;
  int total = 0;

  for (int i = checkPosition - 1; i >= 0; i--) {
    total += weight * [ALPHABET_STRING rangeOfString:[result charAt:i]];
    if (++weight > weightMax) {
      weight = 1;
    }
  }

  if ([result charAt:checkPosition] != ALPHABET[total % 47]) {
    @throw [ChecksumException checksumInstance];
  }
}

@end
