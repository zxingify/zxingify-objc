#import "UPCEANReader.h"

int const MAX_AVG_VARIANCE = (int)(PATTERN_MATCH_RESULT_SCALE_FACTOR * 0.42f);
int const MAX_INDIVIDUAL_VARIANCE = (int)(PATTERN_MATCH_RESULT_SCALE_FACTOR * 0.7f);

/**
 * Start/end guard pattern.
 */
NSArray * const START_END_PATTERN = [NSArray arrayWithObjects:1, 1, 1, nil];

/**
 * Pattern marking the middle of a UPC/EAN pattern, separating the two halves.
 */
NSArray * const MIDDLE_PATTERN = [NSArray arrayWithObjects:1, 1, 1, 1, 1, nil];

/**
 * "Odd", or "L" patterns used to encode UPC/EAN digits.
 */
NSArray * const L_PATTERNS = [NSArray arrayWithObjects:[NSArray arrayWithObjects:3, 2, 1, 1, nil], [NSArray arrayWithObjects:2, 2, 2, 1, nil], [NSArray arrayWithObjects:2, 1, 2, 2, nil], [NSArray arrayWithObjects:1, 4, 1, 1, nil], [NSArray arrayWithObjects:1, 1, 3, 2, nil], [NSArray arrayWithObjects:1, 2, 3, 1, nil], [NSArray arrayWithObjects:1, 1, 1, 4, nil], [NSArray arrayWithObjects:1, 3, 1, 2, nil], [NSArray arrayWithObjects:1, 2, 1, 3, nil], [NSArray arrayWithObjects:3, 1, 1, 2, nil], nil];

/**
 * As above but also including the "even", or "G" patterns used to encode UPC/EAN digits.
 */
NSArray * const L_AND_G_PATTERNS;

@implementation UPCEANReader

+ (void) initialize {
  L_AND_G_PATTERNS = [NSArray array];

  for (int i = 0; i < 10; i++) {
    L_AND_G_PATTERNS[i] = L_PATTERNS[i];
  }


  for (int i = 10; i < 20; i++) {
    NSArray * widths = L_PATTERNS[i - 10];
    NSArray * reversedWidths = [NSArray array];

    for (int j = 0; j < widths.length; j++) {
      reversedWidths[j] = widths[widths.length - j - 1];
    }

    L_AND_G_PATTERNS[i] = reversedWidths;
  }

}

- (id) init {
  if (self = [super init]) {
    decodeRowNSMutableString = [[[NSMutableString alloc] init:20] autorelease];
    extensionReader = [[[UPCEANExtensionSupport alloc] init] autorelease];
    eanManSupport = [[[EANManufacturerOrgSupport alloc] init] autorelease];
  }
  return self;
}

+ (NSArray *) findStartGuardPattern:(BitArray *)row {
  BOOL foundStart = NO;
  NSArray * startRange = nil;
  int nextStart = 0;

  while (!foundStart) {
    startRange = [self findGuardPattern:row rowOffset:nextStart whiteFirst:NO pattern:START_END_PATTERN];
    int start = startRange[0];
    nextStart = startRange[1];
    int quietStart = start - (nextStart - start);
    if (quietStart >= 0) {
      foundStart = [row isRange:quietStart param1:start param2:NO];
    }
  }

  return startRange;
}

- (Result *) decodeRow:(int)rowNumber row:(BitArray *)row hints:(NSMutableDictionary *)hints {
  return [self decodeRow:rowNumber row:row startGuardRange:[self findStartGuardPattern:row] hints:hints];
}


/**
 * <p>Like {@link #decodeRow(int, BitArray, java.util.Hashtable)}, but
 * allows caller to inform method about where the UPC/EAN start pattern is
 * found. This allows this to be computed once and reused across many implementations.</p>
 */
- (Result *) decodeRow:(int)rowNumber row:(BitArray *)row startGuardRange:(NSArray *)startGuardRange hints:(NSMutableDictionary *)hints {
  ResultPointCallback * resultPointCallback = hints == nil ? nil : (ResultPointCallback *)[hints objectForKey:DecodeHintType.NEED_RESULT_POINT_CALLBACK];
  if (resultPointCallback != nil) {
    [resultPointCallback foundPossibleResultPoint:[[[ResultPoint alloc] init:(startGuardRange[0] + startGuardRange[1]) / 2.0f param1:rowNumber] autorelease]];
  }
  NSMutableString * result = decodeRowNSMutableString;
  [result setLength:0];
  int endStart = [self decodeMiddle:row startRange:startGuardRange resultString:result];
  if (resultPointCallback != nil) {
    [resultPointCallback foundPossibleResultPoint:[[[ResultPoint alloc] init:endStart param1:rowNumber] autorelease]];
  }
  NSArray * endRange = [self decodeEnd:row endStart:endStart];
  if (resultPointCallback != nil) {
    [resultPointCallback foundPossibleResultPoint:[[[ResultPoint alloc] init:(endRange[0] + endRange[1]) / 2.0f param1:rowNumber] autorelease]];
  }
  int end = endRange[1];
  int quietEnd = end + (end - endRange[0]);
  if (quietEnd >= [row size] || ![row isRange:end param1:quietEnd param2:NO]) {
    @throw [NotFoundException notFoundInstance];
  }
  NSString * resultString = [result description];
  if (![self checkChecksum:resultString]) {
    @throw [ChecksumException checksumInstance];
  }
  float left = (float)(startGuardRange[1] + startGuardRange[0]) / 2.0f;
  float right = (float)(endRange[1] + endRange[0]) / 2.0f;
  BarcodeFormat * format = [self barcodeFormat];
  Result * decodeResult = [[[Result alloc] init:resultString param1:nil param2:[NSArray arrayWithObjects:[[[ResultPoint alloc] init:left param1:(float)rowNumber] autorelease], [[[ResultPoint alloc] init:right param1:(float)rowNumber] autorelease], nil] param3:format] autorelease];

  @try {
    Result * extensionResult = [extensionReader decodeRow:rowNumber param1:row param2:endRange[1]];
    [decodeResult putAllMetadata:[extensionResult resultMetadata]];
    [decodeResult addResultPoints:[extensionResult resultPoints]];
  }
  @catch (ReaderException * re) {
  }
  if ([BarcodeFormat.EAN_13 isEqualTo:format] || [BarcodeFormat.UPC_A isEqualTo:format]) {
    NSString * countryID = [eanManSupport lookupCountryIdentifier:resultString];
    if (countryID != nil) {
      [decodeResult putMetadata:ResultMetadataType.POSSIBLE_COUNTRY param1:countryID];
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
+ (BOOL) checkStandardUPCEANChecksum:(NSString *)s {
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
  return [self findGuardPattern:row rowOffset:endStart whiteFirst:NO pattern:START_END_PATTERN];
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
+ (NSArray *) findGuardPattern:(BitArray *)row rowOffset:(int)rowOffset whiteFirst:(BOOL)whiteFirst pattern:(NSArray *)pattern {
  int patternLength = pattern.length;
  NSArray * counters = [NSArray array];
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
+ (int) decodeDigit:(BitArray *)row counters:(NSArray *)counters rowOffset:(int)rowOffset patterns:(NSArray *)patterns {
  [self recordPattern:row param1:rowOffset param2:counters];
  int bestVariance = MAX_AVG_VARIANCE;
  int bestMatch = -1;
  int max = patterns.length;

  for (int i = 0; i < max; i++) {
    NSArray * pattern = patterns[i];
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


/**
 * Get the format of this decoder.
 * 
 * @return The 1D format.
 */
- (BarcodeFormat *) getBarcodeFormat {
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
