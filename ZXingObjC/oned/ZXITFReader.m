/*
 * Copyright 2012 ZXing authors
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import "ZXBitArray.h"
#import "ZXDecodeHints.h"
#import "ZXErrors.h"
#import "ZXIntArray.h"
#import "ZXITFReader.h"
#import "ZXResult.h"
#import "ZXResultPoint.h"

static int MAX_AVG_VARIANCE;
static int MAX_INDIVIDUAL_VARIANCE;

static const int W = 3; // Pixel width of a wide line
static const int N = 1; // Pixel width of a narrow line

int const DEFAULT_ALLOWED_LENGTHS[11] = { 48, 44, 24, 20, 18, 16, 14, 12, 10, 8, 6 };

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

@end

@implementation ZXITFReader

+ (void)initialize {
  MAX_AVG_VARIANCE = (int)(PATTERN_MATCH_RESULT_SCALE_FACTOR * 0.42f);
  MAX_INDIVIDUAL_VARIANCE = (int)(PATTERN_MATCH_RESULT_SCALE_FACTOR * 0.78f);
}

- (id)init {
  if (self = [super init]) {
    _narrowLineWidth = -1;
  }

  return self;
}

- (ZXResult *)decodeRow:(int)rowNumber row:(ZXBitArray *)row hints:(ZXDecodeHints *)hints error:(NSError **)error {
  ZXIntArray *startRange = [self decodeStart:row];
  ZXIntArray *endRange = [self decodeEnd:row];
  if (!startRange || !endRange) {
    if (error) *error = NotFoundErrorInstance();
    return nil;
  }

  NSMutableString *resultString = [NSMutableString stringWithCapacity:20];
  if (![self decodeMiddle:row payloadStart:startRange.array[1] payloadEnd:endRange.array[0] resultString:resultString]) {
    if (error) *error = NotFoundErrorInstance();
    return nil;
  }

  NSArray *allowedLengths = nil;
  if (hints != nil) {
    allowedLengths = hints.allowedLengths;
  }
  if (allowedLengths == nil) {
    NSMutableArray *temp = [NSMutableArray array];
    for (int i = 0; i < sizeof(DEFAULT_ALLOWED_LENGTHS) / sizeof(int); i++) {
      [temp addObject:@(DEFAULT_ALLOWED_LENGTHS[i])];
    }
    allowedLengths = [NSArray arrayWithArray:temp];
  }

  NSUInteger length = [resultString length];
  BOOL lengthOK = NO;
  for (NSNumber *i in allowedLengths) {
    if (length == [i intValue]) {
      lengthOK = YES;
      break;
    }
  }
  if (!lengthOK) {
    if (error) *error = FormatErrorInstance();
    return nil;
  }

  return [ZXResult resultWithText:resultString
                         rawBytes:nil
                     resultPoints:@[[[ZXResultPoint alloc] initWithX:startRange.array[1] y:(float)rowNumber],
                                    [[ZXResultPoint alloc] initWithX:endRange.array[0] y:(float)rowNumber]]
                           format:kBarcodeFormatITF];
}

/**
 * @param row          row of black/white values to search
 * @param payloadStart offset of start pattern
 * @param resultString NSMutableString to append decoded chars to
 * @return NO if decoding could not complete successfully
 */
- (BOOL)decodeMiddle:(ZXBitArray *)row payloadStart:(int)payloadStart payloadEnd:(int)payloadEnd resultString:(NSMutableString *)resultString {
  // Digits are interleaved in pairs - 5 black lines for one digit, and the
  // 5
  // interleaved white lines for the second digit.
  // Therefore, need to scan 10 lines and then
  // split these into two arrays
  ZXIntArray *counterDigitPair = [[ZXIntArray alloc] initWithLength:10];
  ZXIntArray *counterBlack = [[ZXIntArray alloc] initWithLength:5];
  ZXIntArray *counterWhite = [[ZXIntArray alloc] initWithLength:5];

  while (payloadStart < payloadEnd) {
    // Get 10 runs of black/white.
    if (![ZXOneDReader recordPattern:row start:payloadStart counters:counterDigitPair]) {
      return NO;
    }
    // Split them into each array
    for (int k = 0; k < 5; k++) {
      int twoK = k << 1;
      counterBlack.array[k] = counterDigitPair.array[twoK];
      counterWhite.array[k] = counterDigitPair.array[twoK + 1];
    }

    int bestMatch = [self decodeDigit:counterBlack];
    if (bestMatch == -1) {
      return NO;
    }
    [resultString appendFormat:@"%C", (unichar)('0' + bestMatch)];
    bestMatch = [self decodeDigit:counterWhite];
    if (bestMatch == -1) {
      return NO;
    }
    [resultString appendFormat:@"%C", (unichar)('0' + bestMatch)];

    for (int i = 0; i < counterDigitPair.length; i++) {
      payloadStart += counterDigitPair.array[i];
    }
  }
  return YES;
}

/**
 * Identify where the start of the middle / payload section starts.
 *
 * @param row row of black/white values to search
 * @return Array, containing index of start of 'start block' and end of
 *         'start block'
 */
- (ZXIntArray *)decodeStart:(ZXBitArray *)row {
  int endStart = [self skipWhiteSpace:row];
  if (endStart == -1) {
    return nil;
  }
  ZXIntArray *startPattern = [self findGuardPattern:row rowOffset:endStart pattern:ITF_START_PATTERN patternLen:sizeof(ITF_START_PATTERN)/sizeof(int)];
  if (!startPattern) {
    return nil;
  }

  self.narrowLineWidth = (startPattern.array[1] - startPattern.array[0]) >> 2;

  if (![self validateQuietZone:row startPattern:startPattern.array[0]]) {
    return nil;
  }

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
 * @return NO if the quiet zone cannot be found, a ReaderException is thrown.
 */
- (BOOL)validateQuietZone:(ZXBitArray *)row startPattern:(int)startPattern {
  int quietCount = self.narrowLineWidth * 10;

  for (int i = startPattern - 1; quietCount > 0 && i >= 0; i--) {
    if ([row get:i]) {
      break;
    }
    quietCount--;
  }
  if (quietCount != 0) {
    return NO;
  }
  return YES;
}

/**
 * Skip all whitespace until we get to the first black line.
 *
 * @param row row of black/white values to search
 * @return index of the first black line or -1 if no black lines are found in the row
 */
- (int)skipWhiteSpace:(ZXBitArray *)row {
  int width = [row size];
  int endStart = [row nextSet:0];
  if (endStart == width) {
    return -1;
  }
  return endStart;
}

/**
 * Identify where the end of the middle / payload section ends.
 *
 * @param row row of black/white values to search
 * @return Array, containing index of start of 'end block' and end of 'end
 *         block'
 */
- (ZXIntArray *)decodeEnd:(ZXBitArray *)row {
  [row reverse];

  int endStart = [self skipWhiteSpace:row];
  if (endStart == -1) {
    [row reverse];
    return nil;
  }
  ZXIntArray *endPattern = [self findGuardPattern:row rowOffset:endStart pattern:END_PATTERN_REVERSED patternLen:sizeof(END_PATTERN_REVERSED)/sizeof(int)];
  if (!endPattern) {
    [row reverse];
    return nil;
  }
  [self validateQuietZone:row startPattern:endPattern.array[0]];
  int temp = endPattern.array[0];
  endPattern.array[0] = [row size] - endPattern.array[1];
  endPattern.array[1] = [row size] - temp;
  [row reverse];
  return endPattern;
}

/**
 * @param row       row of black/white values to search
 * @param rowOffset position to start search
 * @param pattern   pattern of counts of number of black and white pixels that are
 *                  being searched for as a pattern
 * @return start/end horizontal offset of guard pattern, as an array of two
 *         ints or nil if pattern is not found
 */
- (ZXIntArray *)findGuardPattern:(ZXBitArray *)row rowOffset:(int)rowOffset pattern:(const int[])pattern patternLen:(int)patternLen {
  int patternLength = patternLen;
  ZXIntArray *counters = [[ZXIntArray alloc] initWithLength:patternLength];
  int width = row.size;
  BOOL isWhite = NO;

  int counterPosition = 0;
  int patternStart = rowOffset;
  for (int x = rowOffset; x < width; x++) {
    if ([row get:x] ^ isWhite) {
      counters.array[counterPosition]++;
    } else {
      if (counterPosition == patternLength - 1) {
        if ([ZXOneDReader patternMatchVariance:counters pattern:pattern maxIndividualVariance:MAX_INDIVIDUAL_VARIANCE] < MAX_AVG_VARIANCE) {
          return [[ZXIntArray alloc] initWithInts:patternStart, x, -1];
        }
        patternStart += counters.array[0] + counters.array[1];
        for (int y = 2; y < patternLength; y++) {
          counters.array[y - 2] = counters.array[y];
        }
        counters.array[patternLength - 2] = 0;
        counters.array[patternLength - 1] = 0;
        counterPosition--;
      } else {
        counterPosition++;
      }
      counters.array[counterPosition] = 1;
      isWhite = !isWhite;
    }
  }

  return nil;
}

/**
 * Attempts to decode a sequence of ITF black/white lines into single
 * digit.
 *
 * @param counters the counts of runs of observed black/white/black/... values
 * @return The decoded digit or -1 if digit cannot be decoded
 */
- (int)decodeDigit:(ZXIntArray *)counters {
  int bestVariance = MAX_AVG_VARIANCE; // worst variance we'll accept
  int bestMatch = -1;
  int max = PATTERNS_LEN;
  for (int i = 0; i < max; i++) {
    int pattern[counters.length];
    for(int ind = 0; ind<counters.length; ind++){
      pattern[ind] = PATTERNS[i][ind];
    }
    int variance = [ZXOneDReader patternMatchVariance:counters pattern:pattern maxIndividualVariance:MAX_INDIVIDUAL_VARIANCE];
    if (variance < bestVariance) {
      bestVariance = variance;
      bestMatch = i;
    }
  }
  if (bestMatch >= 0) {
    return bestMatch;
  } else {
    return -1;
  }
}

@end
