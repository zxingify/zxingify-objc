#import "ChecksumException.h"
#import "DecodeHintType.h"
#import "EANManufacturerOrgSupport.h"
#import "FormatException.h"
#import "ReaderException.h"
#import "Result.h"
#import "ResultPointCallback.h"
#import "UPCEANReader.h"
#import "UPCEANExtensionSupport.h"

int const MAX_AVG_VARIANCE = (int)(PATTERN_MATCH_RESULT_SCALE_FACTOR * 0.42f);
int const MAX_INDIVIDUAL_VARIANCE = (int)(PATTERN_MATCH_RESULT_SCALE_FACTOR * 0.7f);

/**
 * Start/end guard pattern.
 */
int const START_END_PATTERN[3] = {1, 1, 1};

/**
 * Pattern marking the middle of a UPC/EAN pattern, separating the two halves.
 */
int const MIDDLE_PATTERN[5] = {1, 1, 1, 1, 1};

/**
 * "Odd", or "L" patterns used to encode UPC/EAN digits.
 */
int const L_PATTERNS[10][4] = {
  {3, 2, 1, 1}, // 0
  {2, 2, 2, 1}, // 1
  {2, 1, 2, 2}, // 2
  {1, 4, 1, 1}, // 3
  {1, 1, 3, 2}, // 4
  {1, 2, 3, 1}, // 5
  {1, 1, 1, 4}, // 6
  {1, 3, 1, 2}, // 7
  {1, 2, 1, 3}, // 8
  {3, 1, 1, 2}  // 9
};

/**
 * As above but also including the "even", or "G" patterns used to encode UPC/EAN digits.
 */
int L_AND_G_PATTERNS[20][4];

@interface UPCEANReader ()

- (BOOL) checkStandardUPCEANChecksum:(NSString *)s;

@end

@implementation UPCEANReader

+ (void) initialize {
  for (int i = 0; i < 10; i++) {
    for (int j = 0; j < sizeof(L_PATTERNS[i]) / sizeof(int); j++) {
      L_AND_G_PATTERNS[i][j] = L_PATTERNS[i][j];
    }
  }

  for (int i = 10; i < 20; i++) {
    int *widths = (int*)L_PATTERNS[i - 10];
    for (int j = 0; j < sizeof(widths) / sizeof(int); j++) {
      L_AND_G_PATTERNS[i][j] = widths[sizeof(widths) / sizeof(int) - j - 1];
    }
  }
}

- (id) init {
  if (self = [super init]) {
    decodeRowNSMutableString = [[NSMutableString alloc] initWithCapacity:20];
    extensionReader = [[UPCEANExtensionSupport alloc] init];
    eanManSupport = [[EANManufacturerOrgSupport alloc] init];
  }
  return self;
}

+ (NSArray *) findStartGuardPattern:(BitArray *)row {
  BOOL foundStart = NO;
  NSArray * startRange = nil;
  int nextStart = 0;

  while (!foundStart) {
    startRange = [self findGuardPattern:row rowOffset:nextStart whiteFirst:NO pattern:(int*)START_END_PATTERN];
    int start = [[startRange objectAtIndex:0] intValue];
    nextStart = [[startRange objectAtIndex:1] intValue];
    int quietStart = start - (nextStart - start);
    if (quietStart >= 0) {
      foundStart = [row isRange:quietStart end:start value:NO];
    }
  }

  return startRange;
}

- (Result *) decodeRow:(int)rowNumber row:(BitArray *)row hints:(NSMutableDictionary *)hints {
  return [self decodeRow:rowNumber row:row startGuardRange:[UPCEANReader findStartGuardPattern:row] hints:hints];
}


/**
 * <p>Like {@link #decodeRow(int, BitArray, java.util.Hashtable)}, but
 * allows caller to inform method about where the UPC/EAN start pattern is
 * found. This allows this to be computed once and reused across many implementations.</p>
 */
- (Result *) decodeRow:(int)rowNumber row:(BitArray *)row startGuardRange:(NSArray *)startGuardRange hints:(NSMutableDictionary *)hints {
  id<ResultPointCallback> resultPointCallback = hints == nil ? nil : [hints objectForKey:[NSNumber numberWithInt:kDecodeHintTypeNeedResultPointCallback]];
  if (resultPointCallback != nil) {
    [resultPointCallback foundPossibleResultPoint:[[[ResultPoint alloc] initWithX:([[startGuardRange objectAtIndex:0] intValue] + [[startGuardRange objectAtIndex:1] intValue]) / 2.0f y:rowNumber] autorelease]];
  }
  NSMutableString * result = [NSMutableString string];
  int endStart = [self decodeMiddle:row startRange:startGuardRange resultString:result];
  if (resultPointCallback != nil) {
    [resultPointCallback foundPossibleResultPoint:[[[ResultPoint alloc] initWithX:endStart y:rowNumber] autorelease]];
  }
  NSArray * endRange = [self decodeEnd:row endStart:endStart];
  if (resultPointCallback != nil) {
    [resultPointCallback foundPossibleResultPoint:[[[ResultPoint alloc] initWithX:([[endRange objectAtIndex:0] intValue] + [[endRange objectAtIndex:1] intValue]) / 2.0f y:rowNumber] autorelease]];
  }
  int end = [[endRange objectAtIndex:1] intValue];
  int quietEnd = end + (end - [[endRange objectAtIndex:0] intValue]);
  if (quietEnd >= [row size] || ![row isRange:end end:quietEnd value:NO]) {
    @throw [NotFoundException notFoundInstance];
  }
  NSString * resultString = [result description];
  if (![self checkChecksum:resultString]) {
    @throw [ChecksumException checksumInstance];
  }
  float left = (float)([[startGuardRange objectAtIndex:1] intValue] + [[startGuardRange objectAtIndex:0] intValue]) / 2.0f;
  float right = (float)([[endRange objectAtIndex:1] intValue] + [[endRange objectAtIndex:0] intValue]) / 2.0f;
  BarcodeFormat format = [self barcodeFormat];
  Result * decodeResult = [[[Result alloc] initWithText:resultString
                                               rawBytes:nil
                                           resultPoints:[NSArray arrayWithObjects:[[[ResultPoint alloc] initWithX:left y:(float)rowNumber] autorelease], [[[ResultPoint alloc] initWithX:right y:(float)rowNumber] autorelease], nil]
                                                 format:format] autorelease];

  @try {
    Result * extensionResult = [extensionReader decodeRow:rowNumber row:row rowOffset:[[endRange objectAtIndex:1] intValue]];
    [decodeResult putAllMetadata:[extensionResult resultMetadata]];
    [decodeResult addResultPoints:[extensionResult resultPoints]];
  }
  @catch (ReaderException * re) {
  }
  if (format == kBarcodeFormatEan13 || format == kBarcodeFormatUPCA) {
    NSString * countryID = [eanManSupport lookupCountryIdentifier:resultString];
    if (countryID != nil) {
      [decodeResult putMetadata:kResultMetadataTypePossibleCountry value:countryID];
    }
  }
  return decodeResult;
}


/**
 * @return {@link #checkStandardUPCEANChecksum(String)}
 */
- (BOOL) checkChecksum:(NSString *)s {
  return [self checkStandardUPCEANChecksum:s];
}


/**
 * Computes the UPC/EAN checksum on a string of digits, and reports
 * whether the checksum is correct or not.
 * 
 * @param s string of digits to check
 * @return true iff string of digits passes the UPC/EAN checksum algorithm
 * @throws FormatException if the string does not contain only digits
 */
- (BOOL) checkStandardUPCEANChecksum:(NSString *)s {
  int length = [s length];
  if (length == 0) {
    return NO;
  }
  int sum = 0;

  for (int i = length - 2; i >= 0; i -= 2) {
    int digit = (int)[s characterAtIndex:i] - (int)'0';
    if (digit < 0 || digit > 9) {
      @throw [FormatException formatInstance];
    }
    sum += digit;
  }

  sum *= 3;

  for (int i = length - 1; i >= 0; i -= 2) {
    int digit = (int)[s characterAtIndex:i] - (int)'0';
    if (digit < 0 || digit > 9) {
      @throw [FormatException formatInstance];
    }
    sum += digit;
  }

  return sum % 10 == 0;
}

- (NSArray *) decodeEnd:(BitArray *)row endStart:(int)endStart {
  return [UPCEANReader findGuardPattern:row rowOffset:endStart whiteFirst:NO pattern:(int*)START_END_PATTERN];
}


/**
 * @param row row of black/white values to search
 * @param rowOffset position to start search
 * @param whiteFirst if true, indicates that the pattern specifies white/black/white/...
 * pixel counts, otherwise, it is interpreted as black/white/black/...
 * @param pattern pattern of counts of number of black and white pixels that are being
 * searched for as a pattern
 * @return start/end horizontal offset of guard pattern, as an array of two ints
 * @throws NotFoundException if pattern is not found
 */
+ (NSArray *) findGuardPattern:(BitArray *)row rowOffset:(int)rowOffset whiteFirst:(BOOL)whiteFirst pattern:(int[])pattern {
  int patternLength = sizeof((int*)pattern) / sizeof(int);
  int counters[patternLength];
  int width = [row size];
  BOOL isWhite = NO;

  while (rowOffset < width) {
    isWhite = ![row get:rowOffset];
    if (whiteFirst == isWhite) {
      break;
    }
    rowOffset++;
  }

  int counterPosition = 0;
  int patternStart = rowOffset;

  for (int x = rowOffset; x < width; x++) {
    BOOL pixel = [row get:x];
    if (pixel ^ isWhite) {
      counters[counterPosition]++;
    }
     else {
      if (counterPosition == patternLength - 1) {
        if ([self patternMatchVariance:(int*)counters pattern:pattern maxIndividualVariance:MAX_INDIVIDUAL_VARIANCE] < MAX_AVG_VARIANCE) {
          return [NSArray arrayWithObjects:[NSNumber numberWithInt:patternStart], [NSNumber numberWithInt:x], nil];
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
 * Attempts to decode a single UPC/EAN-encoded digit.
 * 
 * @param row row of black/white values to decode
 * @param counters the counts of runs of observed black/white/black/... values
 * @param rowOffset horizontal offset to start decoding from
 * @param patterns the set of patterns to use to decode -- sometimes different encodings
 * for the digits 0-9 are used, and this indicates the encodings for 0 to 9 that should
 * be used
 * @return horizontal offset of first pixel beyond the decoded digit
 * @throws NotFoundException if digit cannot be decoded
 */
+ (int) decodeDigit:(BitArray *)row counters:(int[])counters rowOffset:(int)rowOffset patterns:(int*[])patterns {
  [self recordPattern:row start:rowOffset counters:counters];
  int bestVariance = MAX_AVG_VARIANCE;
  int bestMatch = -1;
  int max = sizeof((int**)patterns) / sizeof(int*);

  for (int i = 0; i < max; i++) {
    int *pattern = (int*)patterns[i];
    int variance = [self patternMatchVariance:counters pattern:pattern maxIndividualVariance:MAX_INDIVIDUAL_VARIANCE];
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


/**
 * Get the format of this decoder.
 * 
 * @return The 1D format.
 */
- (BarcodeFormat) barcodeFormat {
  @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                 reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                               userInfo:nil];
}


/**
 * Subclasses override this to decode the portion of a barcode between the start
 * and end guard patterns.
 * 
 * @param row row of black/white values to search
 * @param startRange start/end offset of start guard pattern
 * @param resultString {@link NSMutableString} to append decoded chars to
 * @return horizontal offset of first pixel after the "middle" that was decoded
 * @throws NotFoundException if decoding could not complete successfully
 */
- (int) decodeMiddle:(BitArray *)row startRange:(NSArray *)startRange resultString:(NSMutableString *)resultString {
}

- (void) dealloc {
  [decodeRowNSMutableString release];
  [extensionReader release];
  [eanManSupport release];
  [super dealloc];
}

@end
