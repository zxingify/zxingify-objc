#import "ZXBitArray.h"
#import "ZXDecodeHints.h"
#import "ZXFormatException.h"
#import "ZXITFReader.h"
#import "ZXNotFoundException.h"
#import "ZXResult.h"
#import "ZXResultPoint.h"

#define MAX_AVG_VARIANCE (int)(PATTERN_MATCH_RESULT_SCALE_FACTOR * 0.42f)
#define MAX_INDIVIDUAL_VARIANCE (int)(PATTERN_MATCH_RESULT_SCALE_FACTOR * 0.8f)

static const int W = 3;
static const int N = 1;

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
const int PATTERNS_LEN = 10;
const int PATTERNS[PATTERNS_LEN][5] = {
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

@interface ZXITFReader ()

@property (nonatomic, assign) int narrowLineWidth;

- (int)decodeDigit:(int[])counters countersSize:(int)countersSize;
- (void)decodeMiddle:(ZXBitArray *)row payloadStart:(int)payloadStart payloadEnd:(int)payloadEnd resultString:(NSMutableString *)resultString;
- (NSArray *)findGuardPattern:(ZXBitArray *)row rowOffset:(int)rowOffset pattern:(int[])pattern patternLen:(int)patternLen;
- (int)skipWhiteSpace:(ZXBitArray *)row;
- (void)validateQuietZone:(ZXBitArray *)row startPattern:(int)startPattern;

@end

@implementation ZXITFReader

@synthesize narrowLineWidth;

- (id)init {
  if (self = [super init]) {
    self.narrowLineWidth = -1;
  }

  return self;
}

- (ZXResult *)decodeRow:(int)rowNumber row:(ZXBitArray *)row hints:(ZXDecodeHints *)hints {
  NSArray * startRange = [self decodeStart:row];
  NSArray * endRange = [self decodeEnd:row];

  NSMutableString * resultString = [NSMutableString stringWithCapacity:20];
  [self decodeMiddle:row payloadStart:[[startRange objectAtIndex:1] intValue] payloadEnd:[[endRange objectAtIndex:0] intValue] resultString:resultString];

  NSArray * allowedLengths = nil;
  if (hints != nil) {
    allowedLengths = hints.allowedLengths;
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
    @throw [ZXFormatException formatInstance];
  }

  return [[[ZXResult alloc] initWithText:resultString
                                rawBytes:nil
                                  length:0
                            resultPoints:[NSArray arrayWithObjects:
                                          [[[ZXResultPoint alloc] initWithX:[[startRange objectAtIndex:1] floatValue] y:(float)rowNumber] autorelease],
                                          [[[ZXResultPoint alloc] initWithX:[[endRange objectAtIndex:0] floatValue] y:(float)rowNumber] autorelease], nil]
                                  format:kBarcodeFormatITF] autorelease];
}


- (void)decodeMiddle:(ZXBitArray *)row payloadStart:(int)payloadStart payloadEnd:(int)payloadEnd resultString:(NSMutableString *)resultString {
  const int counterDigitPairLen = 10;
  int counterDigitPair[counterDigitPairLen] = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0};

  const int counterBlackLen = 5;
  int counterBlack[counterBlackLen] = {0, 0, 0, 0, 0};

  const int counterWhiteLen = 5;
  int counterWhite[counterWhiteLen] = {0, 0, 0, 0, 0};

  while (payloadStart < payloadEnd) {
    [ZXOneDReader recordPattern:row start:payloadStart counters:counterDigitPair countersSize:counterDigitPairLen];

    for (int k = 0; k < 5; k++) {
      int twoK = k << 1;
      counterBlack[k] = counterDigitPair[twoK];
      counterWhite[k] = counterDigitPair[twoK + 1];
    }

    int bestMatch = [self decodeDigit:counterBlack countersSize:counterBlackLen];
    [resultString appendFormat:@"%C", (unichar)('0' + bestMatch)];
    bestMatch = [self decodeDigit:counterWhite countersSize:counterWhiteLen];
    [resultString appendFormat:@"%C", (unichar)('0' + bestMatch)];

    for (int i = 0; i < sizeof(counterDigitPair) / sizeof(int); i++) {
      payloadStart += counterDigitPair[i];
    }
  }
}


/**
 * Identify where the start of the middle / payload section starts.
 */
- (NSArray *)decodeStart:(ZXBitArray *)row {
  int endStart = [self skipWhiteSpace:row];
  NSArray * startPattern = [self findGuardPattern:row rowOffset:endStart pattern:(int*)ITF_START_PATTERN patternLen:sizeof(ITF_START_PATTERN)/sizeof(int)];

  self.narrowLineWidth = ([[startPattern objectAtIndex:1] intValue] - [[startPattern objectAtIndex:0] intValue]) >> 2;

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
 */
- (void)validateQuietZone:(ZXBitArray *)row startPattern:(int)startPattern {
  int quietCount = self.narrowLineWidth * 10;

  for (int i = startPattern - 1; quietCount > 0 && i >= 0; i--) {
    if ([row get:i]) {
      break;
    }
    quietCount--;
  }
  if (quietCount != 0) {
    @throw [ZXNotFoundException notFoundInstance];
  }
}


/**
 * Skip all whitespace until we get to the first black line.
 */
- (int)skipWhiteSpace:(ZXBitArray *)row {
  int width = [row size];
  int endStart = 0;

  while (endStart < width) {
    if ([row get:endStart]) {
      break;
    }
    endStart++;
  }

  if (endStart == width) {
    @throw [ZXNotFoundException notFoundInstance];
  }
  return endStart;
}


/**
 * Identify where the end of the middle / payload section ends.
 */
- (NSArray *)decodeEnd:(ZXBitArray *)row {
  [row reverse];

  @try {
    int endStart = [self skipWhiteSpace:row];
    NSMutableArray * endPattern = [[[self findGuardPattern:row rowOffset:endStart pattern:(int*)END_PATTERN_REVERSED patternLen:sizeof(END_PATTERN_REVERSED)/sizeof(int)] mutableCopy] autorelease];
    [self validateQuietZone:row startPattern:[[endPattern objectAtIndex:0] intValue]];
    int temp = [[endPattern objectAtIndex:0] intValue];
    [endPattern replaceObjectAtIndex:0 withObject:[NSNumber numberWithInt:[row size] - [[endPattern objectAtIndex:1] intValue]]];
    [endPattern replaceObjectAtIndex:1 withObject:[NSNumber numberWithInt:[row size] - temp]];
    return endPattern;
  } @finally {
    [row reverse];
  }
}

- (NSArray *)findGuardPattern:(ZXBitArray *)row rowOffset:(int)rowOffset pattern:(int[])pattern patternLen:(int)patternLen {
  int patternLength = patternLen;
  int counters[patternLength];
  for (int i=0; i<patternLength; i++) {
    counters[i] = 0;
  }
  int width = row.size;
  BOOL isWhite = NO;

  int counterPosition = 0;
  int patternStart = rowOffset;
  for (int x = rowOffset; x < width; x++) {
    BOOL pixel = [row get:x];
    if (pixel ^ isWhite) {
      counters[counterPosition]++;
    } else {
      if (counterPosition == patternLength - 1) {
        if ([ZXOneDReader patternMatchVariance:counters countersSize:patternLength pattern:pattern maxIndividualVariance:MAX_INDIVIDUAL_VARIANCE] < MAX_AVG_VARIANCE) {
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

  @throw [ZXNotFoundException notFoundInstance];
}


/**
 * Attempts to decode a sequence of ITF black/white lines into single
 * digit.
 */
- (int)decodeDigit:(int[])counters countersSize:(int)countersSize {
  int bestVariance = MAX_AVG_VARIANCE;
  int bestMatch = -1;
  int max = PATTERNS_LEN;
  for (int i = 0; i < max; i++) {
    int pattern[countersSize];
    for(int ind = 0; ind<countersSize; ind++){
      pattern[ind] = PATTERNS[i][ind];
    }
    int variance = [ZXOneDReader patternMatchVariance:counters countersSize:countersSize pattern:pattern maxIndividualVariance:MAX_INDIVIDUAL_VARIANCE];
    if (variance < bestVariance) {
      bestVariance = variance;
      bestMatch = i;
    }
  }
  if (bestMatch >= 0) {
    return bestMatch;
  } else {
    @throw [ZXNotFoundException notFoundInstance];
  }
}

@end
