#import "ZXChecksumException.h"
#import "ZXDecodeHintType.h"
#import "ZXEANManufacturerOrgSupport.h"
#import "ZXFormatException.h"
#import "ZXNotFoundException.h"
#import "ZXReaderException.h"
#import "ZXResult.h"
#import "ZXResultPoint.h"
#import "ZXResultPointCallback.h"
#import "ZXUPCEANReader.h"
#import "ZXUPCEANExtensionSupport.h"

#define MAX_AVG_VARIANCE (int)(PATTERN_MATCH_RESULT_SCALE_FACTOR * 0.42f)
#define MAX_INDIVIDUAL_VARIANCE (int)(PATTERN_MATCH_RESULT_SCALE_FACTOR * 0.7f)

/**
 * Start/end guard pattern.
 */
const int START_END_PATTERN[3] = {1, 1, 1};

/**
 * Pattern marking the middle of a UPC/EAN pattern, separating the two halves.
 */
const int MIDDLE_PATTERN_LEN = 5;
const int MIDDLE_PATTERN[MIDDLE_PATTERN_LEN] = {1, 1, 1, 1, 1};

/**
 * "Odd", or "L" patterns used to encode UPC/EAN digits.
 */
const int L_PATTERNS_LEN = 10;
const int L_PATTERNS_SUB_LEN = 4;
const int L_PATTERNS[L_PATTERNS_LEN][L_PATTERNS_SUB_LEN] = {
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
const int L_AND_G_PATTERNS_LEN = 20;
const int L_AND_G_PATTERNS_SUB_LEN = 4;
const int L_AND_G_PATTERNS[L_AND_G_PATTERNS_LEN][L_AND_G_PATTERNS_SUB_LEN] = {
  {3, 2, 1, 1}, // 0
  {2, 2, 2, 1}, // 1
  {2, 1, 2, 2}, // 2
  {1, 4, 1, 1}, // 3
  {1, 1, 3, 2}, // 4
  {1, 2, 3, 1}, // 5
  {1, 1, 1, 4}, // 6
  {1, 3, 1, 2}, // 7
  {1, 2, 1, 3}, // 8
  {3, 1, 1, 2}, // 9
  {1, 1, 2, 3}, // 10 reversed 0
  {1, 2, 2, 2}, // 11 reversed 1
  {2, 2, 1, 2}, // 12 reversed 2
  {1, 1, 4, 1}, // 13 reversed 3
  {2, 3, 1, 1}, // 14 reversed 4
  {1, 3, 2, 1}, // 15 reversed 5
  {4, 1, 1, 1}, // 16 reversed 6
  {2, 1, 3, 1}, // 17 reversed 7
  {3, 1, 2, 1}, // 18 reversed 8
  {2, 1, 1, 3}  // 19 reversed 9
};

@interface ZXUPCEANReader ()

- (BOOL) checkStandardUPCEANChecksum:(NSString *)s;

@end

@implementation ZXUPCEANReader

- (id) init {
  if (self = [super init]) {
    decodeRowNSMutableString = [[NSMutableString alloc] initWithCapacity:20];
    extensionReader = [[ZXUPCEANExtensionSupport alloc] init];
    eanManSupport = [[ZXEANManufacturerOrgSupport alloc] init];
  }
  return self;
}

+ (NSArray *) findStartGuardPattern:(ZXBitArray *)row {
  BOOL foundStart = NO;
  NSArray * startRange = nil;
  int nextStart = 0;

  while (!foundStart) {
    startRange = [self findGuardPattern:row rowOffset:nextStart whiteFirst:NO pattern:(int*)START_END_PATTERN patternLen:sizeof(START_END_PATTERN)/sizeof(int)];
    int start = [[startRange objectAtIndex:0] intValue];
    nextStart = [[startRange objectAtIndex:1] intValue];
    int quietStart = start - (nextStart - start);
    if (quietStart >= 0) {
      foundStart = [row isRange:quietStart end:start value:NO];
    }
  }

  return startRange;
}

- (ZXResult *) decodeRow:(int)rowNumber row:(ZXBitArray *)row hints:(NSMutableDictionary *)hints {
  return [self decodeRow:rowNumber row:row startGuardRange:[ZXUPCEANReader findStartGuardPattern:row] hints:hints];
}


/**
 * <p>Like {@link #decodeRow(int, BitArray, java.util.Hashtable)}, but
 * allows caller to inform method about where the UPC/EAN start pattern is
 * found. This allows this to be computed once and reused across many implementations.</p>
 */
- (ZXResult *) decodeRow:(int)rowNumber row:(ZXBitArray *)row startGuardRange:(NSArray *)startGuardRange hints:(NSMutableDictionary *)hints {
  id<ZXResultPointCallback> resultPointCallback = hints == nil ? nil : [hints objectForKey:[NSNumber numberWithInt:kDecodeHintTypeNeedResultPointCallback]];
  if (resultPointCallback != nil) {
    [resultPointCallback foundPossibleResultPoint:[[[ZXResultPoint alloc] initWithX:([[startGuardRange objectAtIndex:0] intValue] + [[startGuardRange objectAtIndex:1] intValue]) / 2.0f y:rowNumber] autorelease]];
  }
  NSMutableString * result = [NSMutableString string];
  int endStart = [self decodeMiddle:row startRange:startGuardRange result:result];
  if (resultPointCallback != nil) {
    [resultPointCallback foundPossibleResultPoint:[[[ZXResultPoint alloc] initWithX:endStart y:rowNumber] autorelease]];
  }
  NSArray * endRange = [self decodeEnd:row endStart:endStart];
  if (resultPointCallback != nil) {
    [resultPointCallback foundPossibleResultPoint:[[[ZXResultPoint alloc] initWithX:([[endRange objectAtIndex:0] intValue] + [[endRange objectAtIndex:1] intValue]) / 2.0f y:rowNumber] autorelease]];
  }
  int end = [[endRange objectAtIndex:1] intValue];
  int quietEnd = end + (end - [[endRange objectAtIndex:0] intValue]);
  if (quietEnd >= [row size] || ![row isRange:end end:quietEnd value:NO]) {
    @throw [ZXNotFoundException notFoundInstance];
  }
  NSString * resultString = [result description];
  if (![self checkChecksum:resultString]) {
    @throw [ZXChecksumException checksumInstance];
  }
  float left = (float)([[startGuardRange objectAtIndex:1] intValue] + [[startGuardRange objectAtIndex:0] intValue]) / 2.0f;
  float right = (float)([[endRange objectAtIndex:1] intValue] + [[endRange objectAtIndex:0] intValue]) / 2.0f;
  ZXBarcodeFormat format = [self barcodeFormat];
  ZXResult * decodeResult = [[[ZXResult alloc] initWithText:resultString
                                               rawBytes:nil
                                                 length:0
                                           resultPoints:[NSArray arrayWithObjects:[[[ZXResultPoint alloc] initWithX:left y:(float)rowNumber] autorelease], [[[ZXResultPoint alloc] initWithX:right y:(float)rowNumber] autorelease], nil]
                                                 format:format] autorelease];

  @try {
    ZXResult * extensionResult = [extensionReader decodeRow:rowNumber row:row rowOffset:[[endRange objectAtIndex:1] intValue]];
    [decodeResult putAllMetadata:[extensionResult resultMetadata]];
    [decodeResult addResultPoints:[extensionResult resultPoints]];
  }
  @catch (ZXReaderException * re) {
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
      @throw [ZXFormatException formatInstance];
    }
    sum += digit;
  }

  sum *= 3;

  for (int i = length - 1; i >= 0; i -= 2) {
    int digit = (int)[s characterAtIndex:i] - (int)'0';
    if (digit < 0 || digit > 9) {
      @throw [ZXFormatException formatInstance];
    }
    sum += digit;
  }

  return sum % 10 == 0;
}

- (NSArray *) decodeEnd:(ZXBitArray *)row endStart:(int)endStart {
  return [ZXUPCEANReader findGuardPattern:row rowOffset:endStart whiteFirst:NO pattern:(int*)START_END_PATTERN patternLen:sizeof(START_END_PATTERN)/sizeof(int)];
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
+ (NSArray *) findGuardPattern:(ZXBitArray *)row rowOffset:(int)rowOffset whiteFirst:(BOOL)whiteFirst pattern:(int[])pattern patternLen:(int)patternLen {
  int patternLength = patternLen;
  int counters[patternLength];
  int countersCount = sizeof(counters) / sizeof(int);
  for (int i = 0; i < countersCount; i++) {
    counters[i] = 0;
  }
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
    } else {
      if (counterPosition == patternLength - 1) {
        if ([self patternMatchVariance:counters countersSize:countersCount pattern:pattern maxIndividualVariance:MAX_INDIVIDUAL_VARIANCE] < MAX_AVG_VARIANCE) {
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

  @throw [ZXNotFoundException notFoundInstance];
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
+ (int) decodeDigit:(ZXBitArray *)row counters:(int[])counters countersLen:(int)countersLen rowOffset:(int)rowOffset patternType:(UPC_EAN_PATTERNS)patternType {
  [self recordPattern:row start:rowOffset counters:counters];
  int bestVariance = MAX_AVG_VARIANCE;
  int bestMatch = -1;
  int max = 0;
  switch (patternType) {
    case UPC_EAN_PATTERNS_L_PATTERNS:
      max = L_PATTERNS_LEN;
      for (int i = 0; i < max; i++) {
        int pattern[countersLen];
        for(int j = 0; j< countersLen; j++){
          pattern[j] = L_PATTERNS[i][j];
        }

        int variance = [self patternMatchVariance:counters countersSize:countersLen pattern:pattern maxIndividualVariance:MAX_INDIVIDUAL_VARIANCE];
        if (variance < bestVariance) {
          bestVariance = variance;
          bestMatch = i;
        }
      }
      break;
    case UPC_EAN_PATTERNS_L_AND_G_PATTERNS:
      max = L_AND_G_PATTERNS_LEN;
      for (int i = 0; i < max; i++) {
        int pattern[countersLen];
        for(int j = 0; j< countersLen; j++){
          pattern[j] = L_AND_G_PATTERNS[i][j];
        }
        
        int variance = [self patternMatchVariance:counters countersSize:countersLen pattern:pattern maxIndividualVariance:MAX_INDIVIDUAL_VARIANCE];
        if (variance < bestVariance) {
          bestVariance = variance;
          bestMatch = i;
        }
      }
      break;
    default:
      break;
  }

  if (bestMatch >= 0) {
    return bestMatch;
  } else {
    @throw [ZXNotFoundException notFoundInstance];
  }
}


/**
 * Get the format of this decoder.
 * 
 * @return The 1D format.
 */
- (ZXBarcodeFormat) barcodeFormat {
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
- (int) decodeMiddle:(ZXBitArray *)row startRange:(NSArray *)startRange result:(NSMutableString *)result {
  @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                 reason:[NSString stringWithFormat:@"You must override %@ in a subclass", NSStringFromSelector(_cmd)]
                               userInfo:nil];
}

- (void) dealloc {
  [decodeRowNSMutableString release];
  [extensionReader release];
  [eanManSupport release];
  [super dealloc];
}

@end
