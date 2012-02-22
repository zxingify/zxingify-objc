#import "AbstractExpandedDecoder.h"
#import "BitArrayBuilder.h"
#import "DataCharacter.h"
#import "ExpandedPair.h"
#import "RSSExpandedReader.h"
#import "RSSFinderPattern.h"
#import "RSSUtils.h"

const int SYMBOL_WIDEST[5] = {7, 5, 4, 3, 1};
const int EVEN_TOTAL_SUBSET[5] = {4, 20, 52, 104, 204};
const int GSUM[5] = {0, 348, 1388, 2948, 3988};

const int RSS_EXPANDED_FINDER_PATTERNS[6][4] = {
  {1,8,4,1}, // A
  {3,6,4,1}, // B
  {3,4,6,1}, // C
  {3,2,8,1}, // D
  {2,6,5,1}, // E
  {2,2,9,1}  // F
};

const int WEIGHTS[23][8] = {
  {  1,   3,   9,  27,  81,  32,  96,  77},
  { 20,  60, 180, 118, 143,   7,  21,  63},
  {189, 145,  13,  39, 117, 140, 209, 205},
  {193, 157,  49, 147,  19,  57, 171,  91},
  { 62, 186, 136, 197, 169,  85,  44, 132},
  {185, 133, 188, 142,   4,  12,  36, 108},
  {113, 128, 173,  97,  80,  29,  87,  50},
  {150,  28,  84,  41, 123, 158,  52, 156},
  { 46, 138, 203, 187, 139, 206, 196, 166},
  { 76,  17,  51, 153,  37, 111, 122, 155},
  { 43, 129, 176, 106, 107, 110, 119, 146},
  { 16,  48, 144,  10,  30,  90,  59, 177},
  {109, 116, 137, 200, 178, 112, 125, 164},
  { 70, 210, 208, 202, 184, 130, 179, 115},
  {134, 191, 151,  31,  93,  68, 204, 190},
  {148,  22,  66, 198, 172,   94, 71,   2},
  {  6,  18,  54, 162,  64,  192,154,  40},
  {120, 149,  25,  75,  14,   42,126, 167},
  { 79,  26,  78,  23,  69,  207,199, 175},
  {103,  98,  83,  38, 114, 131, 182, 124},
  {161,  61, 183, 127, 170,  88,  53, 159},
  { 55, 165,  73,   8,  24,  72,   5,  15},
  { 45, 135, 194, 160,  58, 174, 100,  89}
};

const int FINDER_PAT_A = 0;
const int FINDER_PAT_B = 1;
const int FINDER_PAT_C = 2;
const int FINDER_PAT_D = 3;
const int FINDER_PAT_E = 4;
const int FINDER_PAT_F = 5;

const int FINDER_PATTERN_SEQUENCES[10][11] = {
  { FINDER_PAT_A, FINDER_PAT_A },
  { FINDER_PAT_A, FINDER_PAT_B, FINDER_PAT_B },
  { FINDER_PAT_A, FINDER_PAT_C, FINDER_PAT_B, FINDER_PAT_D },
  { FINDER_PAT_A, FINDER_PAT_E, FINDER_PAT_B, FINDER_PAT_D, FINDER_PAT_C },
  { FINDER_PAT_A, FINDER_PAT_E, FINDER_PAT_B, FINDER_PAT_D, FINDER_PAT_D, FINDER_PAT_F },
  { FINDER_PAT_A, FINDER_PAT_E, FINDER_PAT_B, FINDER_PAT_D, FINDER_PAT_E, FINDER_PAT_F, FINDER_PAT_F },
  { FINDER_PAT_A, FINDER_PAT_A, FINDER_PAT_B, FINDER_PAT_B, FINDER_PAT_C, FINDER_PAT_C, FINDER_PAT_D, FINDER_PAT_D },
  { FINDER_PAT_A, FINDER_PAT_A, FINDER_PAT_B, FINDER_PAT_B, FINDER_PAT_C, FINDER_PAT_C, FINDER_PAT_D, FINDER_PAT_E, FINDER_PAT_E },
  { FINDER_PAT_A, FINDER_PAT_A, FINDER_PAT_B, FINDER_PAT_B, FINDER_PAT_C, FINDER_PAT_C, FINDER_PAT_D, FINDER_PAT_E, FINDER_PAT_F, FINDER_PAT_F },
  { FINDER_PAT_A, FINDER_PAT_A, FINDER_PAT_B, FINDER_PAT_B, FINDER_PAT_C, FINDER_PAT_D, FINDER_PAT_D, FINDER_PAT_E, FINDER_PAT_E, FINDER_PAT_F, FINDER_PAT_F },
};

const int LONGEST_SEQUENCE_SIZE = sizeof(FINDER_PATTERN_SEQUENCES[(sizeof(FINDER_PATTERN_SEQUENCES) / sizeof(int*)) - 1]) / sizeof(int);
const int MAX_PAIRS = 11;

@interface RSSExpandedReader () {
  NSMutableArray *pairs;
  int startEnd[2];
  int currentSequence[LONGEST_SEQUENCE_SIZE];
}

- (void) adjustOddEvenCounts:(int)numModules;
- (Result *) constructResult:(NSMutableArray *)pairs;
- (BOOL) checkChecksum;
- (BOOL) checkPairSequence:(NSMutableArray *)previousPairs pattern:(RSSFinderPattern *)pattern;
- (DataCharacter *) decodeDataCharacter:(BitArray *)row pattern:(RSSFinderPattern *)pattern isOddPattern:(BOOL)isOddPattern leftChar:(BOOL)leftChar;
- (void) findNextPair:(BitArray *)row previousPairs:(NSMutableArray *)previousPairs forcedOffset:(int)forcedOffset;
- (int) getNextSecondBar:(BitArray *)row initialPos:(int)initialPos;
- (BOOL) isNotA1left:(RSSFinderPattern *)pattern isOddPattern:(BOOL)isOddPattern leftChar:(BOOL)leftChar;
- (RSSFinderPattern *) parseFoundFinderPattern:(BitArray *)row rowNumber:(int)rowNumber oddPattern:(BOOL)oddPattern;
- (void) reverseCounters:(int[])counters;

@end

@implementation RSSExpandedReader

- (Result *) decodeRow:(int)rowNumber row:(BitArray *)row hints:(NSMutableDictionary *)hints {
  [self reset];
  [self decodeRow2pairs:rowNumber row:row];
  return [self constructResult:pairs];
}

- (void) reset {
  [pairs removeAllObjects];
}

- (NSMutableArray *) decodeRow2pairs:(int)rowNumber row:(BitArray *)row {
  while (YES) {
    ExpandedPair * nextPair = [self retrieveNextPair:row previousPairs:pairs rowNumber:rowNumber];
    [pairs addObject:nextPair];
    if ([nextPair mayBeLast]) {
      if ([self checkChecksum]) {
        return pairs;
      }
      if ([nextPair mustBeLast]) {
        @throw [NotFoundException notFoundInstance];
      }
    }
  }

}

- (Result *) constructResult:(NSMutableArray *)_pairs {
  BitArray * binary = [BitArrayBuilder buildBitArray:_pairs];
  AbstractExpandedDecoder * decoder = [AbstractExpandedDecoder createDecoder:binary];
  NSString * resultingString = [decoder parseInformation];
  NSArray * firstPoints = [[((ExpandedPair *)[_pairs objectAtIndex:0]) finderPattern] resultPoints];
  NSArray * lastPoints = [[((ExpandedPair *)[_pairs lastObject]) finderPattern] resultPoints];
  return [[[Result alloc] initWithText:resultingString
                              rawBytes:nil
                          resultPoints:[NSArray arrayWithObjects:[firstPoints objectAtIndex:0], [firstPoints objectAtIndex:1], [lastPoints objectAtIndex:0], [lastPoints objectAtIndex:1], nil]
                                format:kBarcodeFormatRSSExpanded] autorelease];
}

- (BOOL) checkChecksum {
  ExpandedPair * firstPair = (ExpandedPair *)[pairs objectAtIndex:0];
  DataCharacter * checkCharacter = [firstPair leftChar];
  DataCharacter * firstCharacter = [firstPair rightChar];
  int checksum = [firstCharacter checksumPortion];
  int S = 2;

  for (ExpandedPair *currentPair in pairs) {
    checksum += [[currentPair leftChar] checksumPortion];
    S++;
    if ([currentPair rightChar] != nil) {
      checksum += [[currentPair rightChar] checksumPortion];
      S++;
    }
  }

  checksum %= 211;
  int checkCharacterValue = 211 * (S - 4) + checksum;
  return checkCharacterValue == [checkCharacter value];
}

- (int) getNextSecondBar:(BitArray *)row initialPos:(int)initialPos {
  int currentPos = initialPos;
  BOOL current = [row get:currentPos];

  while (currentPos < row.size && [row get:currentPos] == current) {
    currentPos++;
  }

  current = !current;

  while (currentPos < row.size && [row get:currentPos] == current) {
    currentPos++;
  }

  return currentPos;
}

- (ExpandedPair *) retrieveNextPair:(BitArray *)row previousPairs:(NSMutableArray *)previousPairs rowNumber:(int)rowNumber {
  BOOL isOddPattern = [previousPairs count] % 2 == 0;
  RSSFinderPattern * pattern;
  BOOL keepFinding = YES;
  int forcedOffset = -1;

  do {
    [self findNextPair:row previousPairs:previousPairs forcedOffset:forcedOffset];
    pattern = [self parseFoundFinderPattern:row rowNumber:rowNumber oddPattern:isOddPattern];
    if (pattern == nil) {
      forcedOffset = [self getNextSecondBar:row initialPos:startEnd[0]];
    }
     else {
      keepFinding = NO;
    }
  } while (keepFinding);
  BOOL mayBeLast = [self checkPairSequence:previousPairs pattern:pattern];
  DataCharacter * leftChar = [self decodeDataCharacter:row pattern:pattern isOddPattern:isOddPattern leftChar:YES];
  DataCharacter * rightChar;

  @try {
    rightChar = [self decodeDataCharacter:row pattern:pattern isOddPattern:isOddPattern leftChar:NO];
  }
  @catch (NotFoundException * nfe) {
    if (mayBeLast) {
      rightChar = nil;
    }
     else {
      @throw nfe;
    }
  }
  return [[[ExpandedPair alloc] initWithLeftChar:leftChar rightChar:rightChar finderPattern:pattern mayBeLast:mayBeLast] autorelease];
}

- (BOOL) checkPairSequence:(NSMutableArray *)previousPairs pattern:(RSSFinderPattern *)pattern {
  int currentSequenceLength = [previousPairs count] + 1;
  if (currentSequenceLength > sizeof(currentSequence) / sizeof(int)) {
    @throw [NotFoundException notFoundInstance];
  }

  for (int pos = 0; pos < [previousPairs count]; ++pos) {
    currentSequence[pos] = [[[previousPairs objectAtIndex:pos] finderPattern] value];
  }

  currentSequence[currentSequenceLength - 1] = [pattern value];

  for (int i = 0; i < sizeof(FINDER_PATTERN_SEQUENCES) / sizeof(int*); ++i) {
    int * validSequence = (int*)FINDER_PATTERN_SEQUENCES[i];
    if (sizeof(validSequence) / sizeof(int) >= currentSequenceLength) {
      BOOL valid = YES;

      for (int pos = 0; pos < currentSequenceLength; ++pos) {
        if (currentSequence[pos] != validSequence[pos]) {
          valid = NO;
          break;
        }
      }

      if (valid) {
        return currentSequenceLength == sizeof(validSequence) / sizeof(int);
      }
    }
  }

  @throw [NotFoundException notFoundInstance];
}

- (void) findNextPair:(BitArray *)row previousPairs:(NSMutableArray *)previousPairs forcedOffset:(int)forcedOffset {
  int counters[4] = {0, 0, 0, 0};

  int width = [row size];

  int rowOffset;
  if (forcedOffset >= 0) {
    rowOffset = forcedOffset;
  } else if ([previousPairs count] == 0) {
    rowOffset = 0;
  } else {
    ExpandedPair * lastPair = (ExpandedPair *)[previousPairs lastObject];
    rowOffset = [[[[lastPair finderPattern] startEnd] objectAtIndex:1] intValue];
  }
  BOOL searchingEvenPair = [previousPairs count] % 2 != 0;

  BOOL isWhite = NO;
  while (rowOffset < width) {
    isWhite = ![row get:rowOffset];
    if (!isWhite) {
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
      if (counterPosition == 3) {
        if (searchingEvenPair) {
          [self reverseCounters:counters];
        }

        if ([AbstractRSSReader isFinderPattern:counters]) {
          startEnd[0] = patternStart;
          startEnd[1] = x;
          return;
        }

        if (searchingEvenPair) {
          [self reverseCounters:counters];
        }

        patternStart += counters[0] + counters[1];
        counters[0] = counters[2];
        counters[1] = counters[3];
        counters[2] = 0;
        counters[3] = 0;
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

- (void) reverseCounters:(int[])counters {
  int length = sizeof((int*)counters) / sizeof(int);
  for(int i = 0; i < length / 2; ++i){
    int tmp = counters[i];
    counters[i] = counters[length - i - 1];
    counters[length - i - 1] = tmp;
  }
}

- (RSSFinderPattern *) parseFoundFinderPattern:(BitArray *)row rowNumber:(int)rowNumber oddPattern:(BOOL)oddPattern {
  int firstCounter;
  int start;
  int end;
  if (oddPattern) {
    int firstElementStart = startEnd[0] - 1;

    while (firstElementStart >= 0 && ![row get:firstElementStart]) {
      firstElementStart--;
    }

    firstElementStart++;
    firstCounter = startEnd[0] - firstElementStart;
    start = firstElementStart;
    end = startEnd[1];
  } else {
    start = startEnd[0];
    int firstElementStart = startEnd[1] + 1;

    while ([row get:firstElementStart] && firstElementStart < row.size) {
      firstElementStart++;
    }

    end = firstElementStart;
    firstCounter = end - startEnd[1];
  }
  int counters[[decodeFinderCounters count]];
  for (int i = [decodeFinderCounters count] - 1; i > 0; i--) {
    counters[i] = [[decodeFinderCounters objectAtIndex:i - 1] intValue];
  }

  counters[0] = firstCounter;
  int value;

  @try {
    value = [AbstractRSSReader parseFinderValue:counters finderPatterns:(int **)RSS_EXPANDED_FINDER_PATTERNS];
  }
  @catch (NotFoundException * nfe) {
    return nil;
  }
  return [[[RSSFinderPattern alloc] initWithValue:value startEnd:[NSArray arrayWithObjects:[NSNumber numberWithInt:start], [NSNumber numberWithInt:end], nil] start:start end:end rowNumber:rowNumber] autorelease];
}

- (DataCharacter *) decodeDataCharacter:(BitArray *)row pattern:(RSSFinderPattern *)pattern isOddPattern:(BOOL)isOddPattern leftChar:(BOOL)leftChar {
  int counters[8];
  counters[0] = 0;
  counters[1] = 0;
  counters[2] = 0;
  counters[3] = 0;
  counters[4] = 0;
  counters[5] = 0;
  counters[6] = 0;
  counters[7] = 0;
  if (leftChar) {
    [OneDReader recordPatternInReverse:row start:[[[pattern startEnd] objectAtIndex:0] intValue] counters:counters];
  } else {
    [OneDReader recordPattern:row start:[[[pattern startEnd] objectAtIndex:1] intValue] + 1 counters:counters];

    for (int i = 0, j = (sizeof(counters) / sizeof(int)) - 1; i < j; i++, j--) {
      int temp = counters[i];
      counters[i] = counters[j];
      counters[j] = temp;
    }

  }
  int numModules = 17;
  float elementWidth = (float)[AbstractRSSReader count:counters] / (float)numModules;
  NSMutableArray * _oddCounts = [[oddCounts mutableCopy] autorelease];
  NSMutableArray * _evenCounts = [[evenCounts mutableCopy] autorelease];
  NSMutableArray * _oddRoundingErrors = [[oddRoundingErrors mutableCopy] autorelease];
  NSMutableArray * _evenRoundingErrors = [[evenRoundingErrors mutableCopy] autorelease];

  for (int i = 0; i < sizeof(counters) / sizeof(int); i++) {
    float value = 1.0f * counters[i] / elementWidth;
    int count = (int)(value + 0.5f);
    if (count < 1) {
      count = 1;
    } else if (count > 8) {
      count = 8;
    }
    int offset = i >> 1;
    if ((i & 0x01) == 0) {
      [_oddCounts replaceObjectAtIndex:offset withObject:[NSNumber numberWithInt:count]];
      [_oddRoundingErrors replaceObjectAtIndex:offset withObject:[NSNumber numberWithInt:value - count]];
    } else {
      [_evenCounts replaceObjectAtIndex:offset withObject:[NSNumber numberWithInt:count]];
      [_evenRoundingErrors replaceObjectAtIndex:offset withObject:[NSNumber numberWithInt:value - count]];
    }
  }

  [self adjustOddEvenCounts:numModules];
  int weightRowNumber = 4 * [pattern value] + (isOddPattern ? 0 : 2) + (leftChar ? 0 : 1) - 1;
  int oddSum = 0;
  int oddChecksumPortion = 0;

  for (int i = [_oddCounts count] - 1; i >= 0; i--) {
    if ([self isNotA1left:pattern isOddPattern:isOddPattern leftChar:leftChar]) {
      int weight = WEIGHTS[weightRowNumber][2 * i];
      oddChecksumPortion += [[_oddCounts objectAtIndex:i] intValue] * weight;
    }
    oddSum += [[_oddCounts objectAtIndex:i] intValue];
  }

  int evenChecksumPortion = 0;
  int evenSum = 0;

  for (int i = [_evenCounts count] - 1; i >= 0; i--) {
    if ([self isNotA1left:pattern isOddPattern:isOddPattern leftChar:leftChar]) {
      int weight = WEIGHTS[weightRowNumber][2 * i + 1];
      evenChecksumPortion += [[_evenCounts objectAtIndex:i] intValue] * weight;
    }
    evenSum += [[_evenCounts objectAtIndex:i] intValue];
  }

  int checksumPortion = oddChecksumPortion + evenChecksumPortion;
  if ((oddSum & 0x01) != 0 || oddSum > 13 || oddSum < 4) {
    @throw [NotFoundException notFoundInstance];
  }
  int group = (13 - oddSum) / 2;
  int oddWidest = SYMBOL_WIDEST[group];
  int evenWidest = 9 - oddWidest;
  int vOdd = [RSSUtils getRSSvalue:_oddCounts maxWidth:oddWidest noNarrow:YES];
  int vEven = [RSSUtils getRSSvalue:_evenCounts maxWidth:evenWidest noNarrow:NO];
  int tEven = EVEN_TOTAL_SUBSET[group];
  int gSum = GSUM[group];
  int value = vOdd * tEven + vEven + gSum;
  return [[[DataCharacter alloc] initWithValue:value checksumPortion:checksumPortion] autorelease];
}

- (BOOL) isNotA1left:(RSSFinderPattern *)pattern isOddPattern:(BOOL)isOddPattern leftChar:(BOOL)leftChar {
  return !([pattern value] == 0 && isOddPattern && leftChar);
}

- (void) adjustOddEvenCounts:(int)numModules {
  int oddSum = [AbstractRSSReader countArray:oddCounts];
  int evenSum = [AbstractRSSReader countArray:evenCounts];
  int mismatch = oddSum + evenSum - numModules;
  BOOL oddParityBad = (oddSum & 0x01) == 1;
  BOOL evenParityBad = (evenSum & 0x01) == 0;
  BOOL incrementOdd = NO;
  BOOL decrementOdd = NO;
  if (oddSum > 13) {
    decrementOdd = YES;
  } else if (oddSum < 4) {
    incrementOdd = YES;
  }
  BOOL incrementEven = NO;
  BOOL decrementEven = NO;
  if (evenSum > 13) {
    decrementEven = YES;
  } else if (evenSum < 4) {
    incrementEven = YES;
  }
  
  if (mismatch == 1) {
    if (oddParityBad) {
      if (evenParityBad) {
        @throw [NotFoundException notFoundInstance];
      }
      decrementOdd = YES;
    } else {
      if (!evenParityBad) {
        @throw [NotFoundException notFoundInstance];
      }
      decrementEven = YES;
    }
  } else if (mismatch == -1) {
    if (oddParityBad) {
      if (evenParityBad) {
        @throw [NotFoundException notFoundInstance];
      }
      incrementOdd = YES;
    } else {
      if (!evenParityBad) {
        @throw [NotFoundException notFoundInstance];
      }
      incrementEven = YES;
    }
  } else if (mismatch == 0) {
    if (oddParityBad) {
      if (!evenParityBad) {
        @throw [NotFoundException notFoundInstance];
      }
      if (oddSum < evenSum) {
        incrementOdd = YES;
        decrementEven = YES;
      } else {
        decrementOdd = YES;
        incrementEven = YES;
      }
    } else {
      if (evenParityBad) {
        @throw [NotFoundException notFoundInstance];
      }
    }
  } else {
    @throw [NotFoundException notFoundInstance];
  }

  if (incrementOdd) {
    if (decrementOdd) {
      @throw [NotFoundException notFoundInstance];
    }
    [AbstractRSSReader increment:oddCounts errors:oddRoundingErrors];
  }
  if (decrementOdd) {
    [AbstractRSSReader decrement:oddCounts errors:oddRoundingErrors];
  }
  if (incrementEven) {
    if (decrementEven) {
      @throw [NotFoundException notFoundInstance];
    }
    [AbstractRSSReader increment:evenCounts errors:oddRoundingErrors];
  }
  if (decrementEven) {
    [AbstractRSSReader decrement:evenCounts errors:evenRoundingErrors];
  }
}

- (void) dealloc {
  [pairs release];
  [super dealloc];
}

@end
