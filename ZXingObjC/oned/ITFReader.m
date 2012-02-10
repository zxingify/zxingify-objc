#import "ITFReader.h"

int const MAX_AVG_VARIANCE = (int)(PATTERN_MATCH_RESULT_SCALE_FACTOR * 0.42f);
int const MAX_INDIVIDUAL_VARIANCE = (int)(PATTERN_MATCH_RESULT_SCALE_FACTOR * 0.8f);
int const W = 3;
int const N = 1;
NSArray * const DEFAULT_ALLOWED_LENGTHS = [NSArray arrayWithObjects:6, 8, 10, 12, 14, 16, 20, 24, 44, nil];

/**
 * Start/end guard pattern.
 * 
 * Note: The end pattern is reversed because the row is reversed before
 * searching for the END_PATTERN
 */
NSArray * const START_PATTERN = [NSArray arrayWithObjects:N, N, N, N, nil];
NSArray * const END_PATTERN_REVERSED = [NSArray arrayWithObjects:N, N, W, nil];

/**
 * Patterns of Wide / Narrow lines to indicate each digit
 */
NSArray * const PATTERNS = [NSArray arrayWithObjects:[NSArray arrayWithObjects:N, N, W, W, N, nil], [NSArray arrayWithObjects:W, N, N, N, W, nil], [NSArray arrayWithObjects:N, W, N, N, W, nil], [NSArray arrayWithObjects:W, W, N, N, N, nil], [NSArray arrayWithObjects:N, N, W, N, W, nil], [NSArray arrayWithObjects:W, N, W, N, N, nil], [NSArray arrayWithObjects:N, W, W, N, N, nil], [NSArray arrayWithObjects:N, N, N, W, W, nil], [NSArray arrayWithObjects:W, N, N, W, N, nil], [NSArray arrayWithObjects:N, W, N, W, N, nil], nil];

@implementation ITFReader

- (void) init {
  if (self = [super init]) {
    narrowLineWidth = -1;
  }
  return self;
}

- (Result *) decodeRow:(int)rowNumber row:(BitArray *)row hints:(NSMutableDictionary *)hints {
  NSArray * startRange = [self decodeStart:row];
  NSArray * endRange = [self decodeEnd:row];
  NSMutableString * result = [[[NSMutableString alloc] init:20] autorelease];
  [self decodeMiddle:row payloadStart:startRange[1] payloadEnd:endRange[0] resultString:result];
  NSString * resultString = [result description];
  NSArray * allowedLengths = nil;
  if (hints != nil) {
    allowedLengths = (NSArray *)[hints objectForKey:DecodeHintType.ALLOWED_LENGTHS];
  }
  if (allowedLengths == nil) {
    allowedLengths = DEFAULT_ALLOWED_LENGTHS;
  }
  int length = [resultString length];
  BOOL lengthOK = NO;

  for (int i = 0; i < allowedLengths.length; i++) {
    if (length == allowedLengths[i]) {
      lengthOK = YES;
      break;
    }
  }

  if (!lengthOK) {
    @throw [FormatException formatInstance];
  }
  return [[[Result alloc] init:resultString param1:nil param2:[NSArray arrayWithObjects:[[[ResultPoint alloc] init:startRange[1] param1:(float)rowNumber] autorelease], [[[ResultPoint alloc] init:endRange[0] param1:(float)rowNumber] autorelease], nil] param3:BarcodeFormat.ITF] autorelease];
}


/**
 * @param row          row of black/white values to search
 * @param payloadStart offset of start pattern
 * @param resultString {@link NSMutableString} to append decoded chars to
 * @throws NotFoundException if decoding could not complete successfully
 */
+ (void) decodeMiddle:(BitArray *)row payloadStart:(int)payloadStart payloadEnd:(int)payloadEnd resultString:(NSMutableString *)resultString {
  NSArray * counterDigitPair = [NSArray array];
  NSArray * counterBlack = [NSArray array];
  NSArray * counterWhite = [NSArray array];

  while (payloadStart < payloadEnd) {
    [self recordPattern:row param1:payloadStart param2:counterDigitPair];

    for (int k = 0; k < 5; k++) {
      int twoK = k << 1;
      counterBlack[k] = counterDigitPair[twoK];
      counterWhite[k] = counterDigitPair[twoK + 1];
    }

    int bestMatch = [self decodeDigit:counterBlack];
    [resultString append:(unichar)('0' + bestMatch)];
    bestMatch = [self decodeDigit:counterWhite];
    [resultString append:(unichar)('0' + bestMatch)];

    for (int i = 0; i < counterDigitPair.length; i++) {
      payloadStart += counterDigitPair[i];
    }

  }

}


/**
 * Identify where the start of the middle / payload section starts.
 * 
 * @param row row of black/white values to search
 * @return Array, containing index of start of 'start block' and end of
 * 'start block'
 * @throws NotFoundException
 */
- (NSArray *) decodeStart:(BitArray *)row {
  int endStart = [self skipWhiteSpace:row];
  NSArray * startPattern = [self findGuardPattern:row rowOffset:endStart pattern:START_PATTERN];
  narrowLineWidth = (startPattern[1] - startPattern[0]) >> 2;
  [self validateQuietZone:row startPattern:startPattern[0]];
  return startPattern;
}


/**
 * The start & end patterns must be pre/post fixed by a quiet zone. This
 * zone must be at least 10 times the width of a narrow line.  Scan back until
 * we either get to the start of the barcode or match the necessary number of
 * quiet zone pixels.
 * 
 * Note: Its assumed the row is reversed when using this method to find
 * quiet zone after the end pattern.
 * 
 * ref: http://www.barcode-1.net/i25code.html
 * 
 * @param row bit array representing the scanned barcode.
 * @param startPattern index into row of the start or end pattern.
 * @throws NotFoundException if the quiet zone cannot be found, a ReaderException is thrown.
 */
- (void) validateQuietZone:(BitArray *)row startPattern:(int)startPattern {
  int quietCount = narrowLineWidth * 10;

  for (int i = startPattern - 1; quietCount > 0 && i >= 0; i--) {
    if ([row get:i]) {
      break;
    }
    quietCount--;
  }

  if (quietCount != 0) {
    @throw [NotFoundException notFoundInstance];
  }
}


/**
 * Skip all whitespace until we get to the first black line.
 * 
 * @param row row of black/white values to search
 * @return index of the first black line.
 * @throws NotFoundException Throws exception if no black lines are found in the row
 */
+ (int) skipWhiteSpace:(BitArray *)row {
  int width = [row size];
  int endStart = 0;

  while (endStart < width) {
    if ([row get:endStart]) {
      break;
    }
    endStart++;
  }

  if (endStart == width) {
    @throw [NotFoundException notFoundInstance];
  }
  return endStart;
}


/**
 * Identify where the end of the middle / payload section ends.
 * 
 * @param row row of black/white values to search
 * @return Array, containing index of start of 'end block' and end of 'end
 * block'
 * @throws NotFoundException
 */
- (NSArray *) decodeEnd:(BitArray *)row {
  [row reverse];

  @try {
    int endStart = [self skipWhiteSpace:row];
    NSArray * endPattern = [self findGuardPattern:row rowOffset:endStart pattern:END_PATTERN_REVERSED];
    [self validateQuietZone:row startPattern:endPattern[0]];
    int temp = endPattern[0];
    endPattern[0] = [row size] - endPattern[1];
    endPattern[1] = [row size] - temp;
    return endPattern;
  }
  @finally {
    [row reverse];
  }
}


/**
 * @param row       row of black/white values to search
 * @param rowOffset position to start search
 * @param pattern   pattern of counts of number of black and white pixels that are
 * being searched for as a pattern
 * @return start/end horizontal offset of guard pattern, as an array of two
 * ints
 * @throws NotFoundException if pattern is not found
 */
+ (NSArray *) findGuardPattern:(BitArray *)row rowOffset:(int)rowOffset pattern:(NSArray *)pattern {
  int patternLength = pattern.length;
  NSArray * counters = [NSArray array];
  int width = [row size];
  BOOL isWhite = NO;
  int counterPosition = 0;
  int patternStart = rowOffset;

  for (int x = rowOffset; x < width; x++) {
    BOOL pixel = [row get:x];
    if (pixel ^ isWhite) {
      counters[counterPosition]++;
    }
     else {
      if (counterPosition == patternLength - 1) {
        if ([self patternMatchVariance:counters param1:pattern param2:MAX_INDIVIDUAL_VARIANCE] < MAX_AVG_VARIANCE) {
          return [NSArray arrayWithObjects:patternStart, x, nil];
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


/**
 * Attempts to decode a sequence of ITF black/white lines into single
 * digit.
 * 
 * @param counters the counts of runs of observed black/white/black/... values
 * @return The decoded digit
 * @throws NotFoundException if digit cannot be decoded
 */
+ (int) decodeDigit:(NSArray *)counters {
  int bestVariance = MAX_AVG_VARIANCE;
  int bestMatch = -1;
  int max = PATTERNS.length;

  for (int i = 0; i < max; i++) {
    NSArray * pattern = PATTERNS[i];
    int variance = [self patternMatchVariance:counters param1:pattern param2:MAX_INDIVIDUAL_VARIANCE];
    if (variance < bestVariance) {
      bestVariance = variance;
      bestMatch = i;
    }
  }

  if (bestMatch >= 0) {
    return bestMatch;
  }
   else {
    @throw [NotFoundException notFoundInstance];
  }
}

@end
