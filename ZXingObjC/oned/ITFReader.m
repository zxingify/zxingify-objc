#import "DecodeHintType.h"
#import "FormatException.h"
#import "ITFReader.h"
#import "NotFoundException.h"
#import "Result.h"
#import "ResultPoint.h"

#define MAX_AVG_VARIANCE (int)(PATTERN_MATCH_RESULT_SCALE_FACTOR * 0.42f)
#define MAX_INDIVIDUAL_VARIANCE (int)(PATTERN_MATCH_RESULT_SCALE_FACTOR * 0.8f)

int const W = 3;
int const N = 1;

int const DEFAULT_ALLOWED_LENGTHS[9] = { 6, 8, 10, 12, 14, 16, 20, 24, 44 };

/**
 * Start/end guard pattern.
 * 
 * Note: The end pattern is reversed because the row is reversed before
 * searching for the END_PATTERN
 */
int const ITF_START_PATTERN[4] = {N, N, N, N};
int const END_PATTERN_REVERSED[3] = {N, N, W};

/**
 * Patterns of Wide / Narrow lines to indicate each digit
 */
int const PATTERNS[10][5] = {
  {N, N, W, W, N}, // 0
  {W, N, N, N, W}, // 1
  {N, W, N, N, W}, // 2
  {W, W, N, N, N}, // 3
  {N, N, W, N, W}, // 4
  {W, N, W, N, N}, // 5
  {N, W, W, N, N}, // 6
  {N, N, N, W, W}, // 7
  {W, N, N, W, N}, // 8
  {N, W, N, W, N}  // 9
};

@interface ITFReader ()

- (int) decodeDigit:(int[])counters;
- (void) decodeMiddle:(BitArray *)row payloadStart:(int)payloadStart payloadEnd:(int)payloadEnd resultString:(NSMutableString *)resultString;
- (NSArray *) findGuardPattern:(BitArray *)row rowOffset:(int)rowOffset pattern:(int[])pattern;
- (int) skipWhiteSpace:(BitArray *)row;
- (void) validateQuietZone:(BitArray *)row startPattern:(int)startPattern;

@end

@implementation ITFReader

- (id) init {
  if (self = [super init]) {
    narrowLineWidth = -1;
  }
  return self;
}

- (Result *) decodeRow:(int)rowNumber row:(BitArray *)row hints:(NSMutableDictionary *)hints {
  NSArray * startRange = [self decodeStart:row];
  NSArray * endRange = [self decodeEnd:row];

  NSMutableString * resultString = [NSMutableString stringWithCapacity:20];
  [self decodeMiddle:row payloadStart:[[startRange objectAtIndex:1] intValue] payloadEnd:[[endRange objectAtIndex:0] intValue] resultString:resultString];

  NSArray * allowedLengths = nil;
  if (hints != nil) {
    allowedLengths = [hints objectForKey:[NSNumber numberWithInt:kDecodeHintTypeAllowedLengths]];
  }
  if (allowedLengths == nil) {
    NSMutableArray *temp = [NSMutableArray array];
    for (int i = 0; i < sizeof(DEFAULT_ALLOWED_LENGTHS) / sizeof(int); i++) {
      [temp addObject:[NSNumber numberWithInt:DEFAULT_ALLOWED_LENGTHS[i]]];
    }
    allowedLengths = [NSArray arrayWithArray:temp];
  }

  int length = [resultString length];
  BOOL lengthOK = NO;
  for (NSNumber *i in allowedLengths) {
    if (length == [i intValue]) {
      lengthOK = YES;
      break;
    }
  }
  if (!lengthOK) {
    @throw [FormatException formatInstance];
  }

  return [[[Result alloc] initWithText:resultString
                                 rawBytes:nil
                                length:0
                          resultPoints:[NSArray arrayWithObjects:[[[ResultPoint alloc] initWithX:[[startRange objectAtIndex:1] floatValue] y:(float)rowNumber] autorelease],
                                        [[[ResultPoint alloc] initWithX:[[endRange objectAtIndex:0] floatValue] y:(float)rowNumber] autorelease], nil]
                                format:kBarcodeFormatITF] autorelease];
}


/**
 * @param row          row of black/white values to search
 * @param payloadStart offset of start pattern
 * @param resultString {@link NSMutableString} to append decoded chars to
 * @throws NotFoundException if decoding could not complete successfully
 */
- (void) decodeMiddle:(BitArray *)row payloadStart:(int)payloadStart payloadEnd:(int)payloadEnd resultString:(NSMutableString *)resultString {
  int counterDigitPair[10] = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0};
  int counterBlack[5] = {0, 0, 0, 0, 0};
  int counterWhite[5] = {0, 0, 0, 0, 0};

  while (payloadStart < payloadEnd) {
    [OneDReader recordPattern:row start:payloadStart counters:counterDigitPair];

    for (int k = 0; k < 5; k++) {
      int twoK = k << 1;
      counterBlack[k] = counterDigitPair[twoK];
      counterWhite[k] = counterDigitPair[twoK + 1];
    }

    int bestMatch = [self decodeDigit:counterBlack];
    [resultString appendFormat:@"%C", (unichar)('0' + bestMatch)];
    bestMatch = [self decodeDigit:counterWhite];
    [resultString appendFormat:@"%C", (unichar)('0' + bestMatch)];

    for (int i = 0; i < sizeof(counterDigitPair) / sizeof(int); i++) {
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
  NSArray * startPattern = [self findGuardPattern:row rowOffset:endStart pattern:(int*)ITF_START_PATTERN];

  narrowLineWidth = ([[startPattern objectAtIndex:1] intValue] - [[startPattern objectAtIndex:0] intValue]) >> 2;

  [self validateQuietZone:row startPattern:[[startPattern objectAtIndex:0] intValue]];

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
- (int) skipWhiteSpace:(BitArray *)row {
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
    NSMutableArray * endPattern = [[[self findGuardPattern:row rowOffset:endStart pattern:(int*)END_PATTERN_REVERSED] mutableCopy] autorelease];
    [self validateQuietZone:row startPattern:[[endPattern objectAtIndex:0] intValue]];
    int temp = [[endPattern objectAtIndex:0] intValue];
    [endPattern replaceObjectAtIndex:0 withObject:[NSNumber numberWithInt:[row size] - [[endPattern objectAtIndex:1] intValue]]];
    [endPattern replaceObjectAtIndex:1 withObject:[NSNumber numberWithInt:[row size] - temp]];
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
- (NSArray *) findGuardPattern:(BitArray *)row rowOffset:(int)rowOffset pattern:(int[])pattern {
  int patternLength = sizeof((int*)pattern) / sizeof(int);
  int counters[patternLength];
  int width = [row size];
  BOOL isWhite = NO;

  int counterPosition = 0;
  int patternStart = rowOffset;
  for (int x = rowOffset; x < width; x++) {
    BOOL pixel = [row get:x];
    if (pixel ^ isWhite) {
      counters[counterPosition]++;
    } else {
      if (counterPosition == patternLength - 1) {
        if ([OneDReader patternMatchVariance:counters pattern:pattern maxIndividualVariance:MAX_INDIVIDUAL_VARIANCE] < MAX_AVG_VARIANCE) {
          return [NSArray arrayWithObjects:[NSNumber numberWithInt:patternStart], [NSNumber numberWithInt:x], nil];
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
- (int) decodeDigit:(int[])counters {
  int bestVariance = MAX_AVG_VARIANCE;
  int bestMatch = -1;
  int max = sizeof(PATTERNS) / sizeof(int*);
  for (int i = 0; i < max; i++) {
    int *pattern = (int*)PATTERNS[i];
    int variance = [OneDReader patternMatchVariance:counters pattern:pattern maxIndividualVariance:MAX_INDIVIDUAL_VARIANCE];
    if (variance < bestVariance) {
      bestVariance = variance;
      bestMatch = i;
    }
  }
  if (bestMatch >= 0) {
    return bestMatch;
  } else {
    @throw [NotFoundException notFoundInstance];
  }
}

@end
