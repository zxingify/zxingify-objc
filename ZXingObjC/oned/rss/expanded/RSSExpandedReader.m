#import "RSSExpandedReader.h"

NSArray * const SYMBOL_WIDEST = [NSArray arrayWithObjects:7, 5, 4, 3, 1, nil];
NSArray * const EVEN_TOTAL_SUBSET = [NSArray arrayWithObjects:4, 20, 52, 104, 204, nil];
NSArray * const GSUM = [NSArray arrayWithObjects:0, 348, 1388, 2948, 3988, nil];
NSArray * const FINDER_PATTERNS = [NSArray arrayWithObjects:[NSArray arrayWithObjects:1, 8, 4, 1, nil], [NSArray arrayWithObjects:3, 6, 4, 1, nil], [NSArray arrayWithObjects:3, 4, 6, 1, nil], [NSArray arrayWithObjects:3, 2, 8, 1, nil], [NSArray arrayWithObjects:2, 6, 5, 1, nil], [NSArray arrayWithObjects:2, 2, 9, 1, nil], nil];
NSArray * const WEIGHTS = [NSArray arrayWithObjects:[NSArray arrayWithObjects:1, 3, 9, 27, 81, 32, 96, 77, nil], [NSArray arrayWithObjects:20, 60, 180, 118, 143, 7, 21, 63, nil], [NSArray arrayWithObjects:189, 145, 13, 39, 117, 140, 209, 205, nil], [NSArray arrayWithObjects:193, 157, 49, 147, 19, 57, 171, 91, nil], [NSArray arrayWithObjects:62, 186, 136, 197, 169, 85, 44, 132, nil], [NSArray arrayWithObjects:185, 133, 188, 142, 4, 12, 36, 108, nil], [NSArray arrayWithObjects:113, 128, 173, 97, 80, 29, 87, 50, nil], [NSArray arrayWithObjects:150, 28, 84, 41, 123, 158, 52, 156, nil], [NSArray arrayWithObjects:46, 138, 203, 187, 139, 206, 196, 166, nil], [NSArray arrayWithObjects:76, 17, 51, 153, 37, 111, 122, 155, nil], [NSArray arrayWithObjects:43, 129, 176, 106, 107, 110, 119, 146, nil], [NSArray arrayWithObjects:16, 48, 144, 10, 30, 90, 59, 177, nil], [NSArray arrayWithObjects:109, 116, 137, 200, 178, 112, 125, 164, nil], [NSArray arrayWithObjects:70, 210, 208, 202, 184, 130, 179, 115, nil], [NSArray arrayWithObjects:134, 191, 151, 31, 93, 68, 204, 190, nil], [NSArray arrayWithObjects:148, 22, 66, 198, 172, 94, 71, 2, nil], [NSArray arrayWithObjects:6, 18, 54, 162, 64, 192, 154, 40, nil], [NSArray arrayWithObjects:120, 149, 25, 75, 14, 42, 126, 167, nil], [NSArray arrayWithObjects:79, 26, 78, 23, 69, 207, 199, 175, nil], [NSArray arrayWithObjects:103, 98, 83, 38, 114, 131, 182, 124, nil], [NSArray arrayWithObjects:161, 61, 183, 127, 170, 88, 53, 159, nil], [NSArray arrayWithObjects:55, 165, 73, 8, 24, 72, 5, 15, nil], [NSArray arrayWithObjects:45, 135, 194, 160, 58, 174, 100, 89, nil], nil];
int const FINDER_PAT_A = 0;
int const FINDER_PAT_B = 1;
int const FINDER_PAT_C = 2;
int const FINDER_PAT_D = 3;
int const FINDER_PAT_E = 4;
int const FINDER_PAT_F = 5;
NSArray * const FINDER_PATTERN_SEQUENCES = [NSArray arrayWithObjects:[NSArray arrayWithObjects:FINDER_PAT_A, FINDER_PAT_A, nil], [NSArray arrayWithObjects:FINDER_PAT_A, FINDER_PAT_B, FINDER_PAT_B, nil], [NSArray arrayWithObjects:FINDER_PAT_A, FINDER_PAT_C, FINDER_PAT_B, FINDER_PAT_D, nil], [NSArray arrayWithObjects:FINDER_PAT_A, FINDER_PAT_E, FINDER_PAT_B, FINDER_PAT_D, FINDER_PAT_C, nil], [NSArray arrayWithObjects:FINDER_PAT_A, FINDER_PAT_E, FINDER_PAT_B, FINDER_PAT_D, FINDER_PAT_D, FINDER_PAT_F, nil], [NSArray arrayWithObjects:FINDER_PAT_A, FINDER_PAT_E, FINDER_PAT_B, FINDER_PAT_D, FINDER_PAT_E, FINDER_PAT_F, FINDER_PAT_F, nil], [NSArray arrayWithObjects:FINDER_PAT_A, FINDER_PAT_A, FINDER_PAT_B, FINDER_PAT_B, FINDER_PAT_C, FINDER_PAT_C, FINDER_PAT_D, FINDER_PAT_D, nil], [NSArray arrayWithObjects:FINDER_PAT_A, FINDER_PAT_A, FINDER_PAT_B, FINDER_PAT_B, FINDER_PAT_C, FINDER_PAT_C, FINDER_PAT_D, FINDER_PAT_E, FINDER_PAT_E, nil], [NSArray arrayWithObjects:FINDER_PAT_A, FINDER_PAT_A, FINDER_PAT_B, FINDER_PAT_B, FINDER_PAT_C, FINDER_PAT_C, FINDER_PAT_D, FINDER_PAT_E, FINDER_PAT_F, FINDER_PAT_F, nil], [NSArray arrayWithObjects:FINDER_PAT_A, FINDER_PAT_A, FINDER_PAT_B, FINDER_PAT_B, FINDER_PAT_C, FINDER_PAT_D, FINDER_PAT_D, FINDER_PAT_E, FINDER_PAT_E, FINDER_PAT_F, FINDER_PAT_F, nil], nil];
int const LONGEST_SEQUENCE_SIZE = FINDER_PATTERN_SEQUENCES[FINDER_PATTERN_SEQUENCES.length - 1].length;
int const MAX_PAIRS = 11;

@implementation RSSExpandedReader

- (void) init {
  if (self = [super init]) {
    pairs = [[[NSMutableArray alloc] init:MAX_PAIRS] autorelease];
    startEnd = [NSArray array];
    currentSequence = [NSArray array];
  }
  return self;
}

- (Result *) decodeRow:(int)rowNumber row:(BitArray *)row hints:(NSMutableDictionary *)hints {
  [self reset];
  [self decodeRow2pairs:rowNumber row:row];
  return [self constructResult:pairs];
}

- (void) reset {
  [pairs setSize:0];
}

- (NSMutableArray *) decodeRow2pairs:(int)rowNumber row:(BitArray *)row {

  while (YES) {
    ExpandedPair * nextPair = [self retrieveNextPair:row previousPairs:pairs rowNumber:rowNumber];
    [pairs addElement:nextPair];
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

+ (Result *) constructResult:(NSMutableArray *)pairs {
  BitArray * binary = [BitArrayBuilder buildBitArray:pairs];
  AbstractExpandedDecoder * decoder = [AbstractExpandedDecoder createDecoder:binary];
  NSString * resultingString = [decoder parseInformation];
  NSArray * firstPoints = [[((ExpandedPair *)[pairs objectAtIndex:0]) finderPattern] resultPoints];
  NSArray * lastPoints = [[((ExpandedPair *)[pairs lastObject]) finderPattern] resultPoints];
  return [[[Result alloc] init:resultingString param1:nil param2:[NSArray arrayWithObjects:firstPoints[0], firstPoints[1], lastPoints[0], lastPoints[1], nil] param3:BarcodeFormat.RSS_EXPANDED] autorelease];
}

- (BOOL) checkChecksum {
  ExpandedPair * firstPair = (ExpandedPair *)[pairs elementAt:0];
  DataCharacter * checkCharacter = [firstPair leftChar];
  DataCharacter * firstCharacter = [firstPair rightChar];
  int checksum = [firstCharacter checksumPortion];
  int S = 2;

  for (int i = 1; i < [pairs size]; ++i) {
    ExpandedPair * currentPair = (ExpandedPair *)[pairs elementAt:i];
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

+ (int) getNextSecondBar:(BitArray *)row initialPos:(int)initialPos {
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
  FinderPattern * pattern;
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
  }
   while (keepFinding);
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
  return [[[ExpandedPair alloc] init:leftChar param1:rightChar param2:pattern param3:mayBeLast] autorelease];
}

- (BOOL) checkPairSequence:(NSMutableArray *)previousPairs pattern:(FinderPattern *)pattern {
  int currentSequenceLength = [previousPairs count] + 1;
  if (currentSequenceLength > currentSequence.length) {
    @throw [NotFoundException notFoundInstance];
  }

  for (int pos = 0; pos < [previousPairs count]; ++pos) {
    currentSequence[pos] = [[((ExpandedPair *)[previousPairs objectAtIndex:pos]) finderPattern] value];
  }

  currentSequence[currentSequenceLength - 1] = [pattern value];

  for (int i = 0; i < FINDER_PATTERN_SEQUENCES.length; ++i) {
    NSArray * validSequence = FINDER_PATTERN_SEQUENCES[i];
    if (validSequence.length >= currentSequenceLength) {
      BOOL valid = YES;

      for (int pos = 0; pos < currentSequenceLength; ++pos) {
        if (currentSequence[pos] != validSequence[pos]) {
          valid = NO;
          break;
        }
      }

      if (valid) {
        return currentSequenceLength == validSequence.length;
      }
    }
  }

  @throw [NotFoundException notFoundInstance];
}

- (void) findNextPair:(BitArray *)row previousPairs:(NSMutableArray *)previousPairs forcedOffset:(int)forcedOffset {
  NSArray * counters = decodeFinderCounters;
  counters[0] = 0;
  counters[1] = 0;
  counters[2] = 0;
  counters[3] = 0;
  int width = [row size];
  int rowOffset;
  if (forcedOffset >= 0) {
    rowOffset = forcedOffset;
  }
   else if ([previousPairs empty]) {
    rowOffset = 0;
  }
   else {
    ExpandedPair * lastPair = (ExpandedPair *)[previousPairs lastObject];
    rowOffset = [[lastPair finderPattern] startEnd][1];
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
    }
     else {
      if (counterPosition == 3) {
        if (searchingEvenPair) {
          [self reverseCounters:counters];
        }
        if ([self isFinderPattern:counters]) {
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

+ (void) reverseCounters:(NSArray *)counters {
  int length = counters.length;

  for (int i = 0; i < length / 2; ++i) {
    int tmp = counters[i];
    counters[i] = counters[length - i - 1];
    counters[length - i - 1] = tmp;
  }

}

- (FinderPattern *) parseFoundFinderPattern:(BitArray *)row rowNumber:(int)rowNumber oddPattern:(BOOL)oddPattern {
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
  }
   else {
    start = startEnd[0];
    int firstElementStart = startEnd[1] + 1;

    while ([row get:firstElementStart] && firstElementStart < row.size) {
      firstElementStart++;
    }

    end = firstElementStart;
    firstCounter = end - startEnd[1];
  }
  NSArray * counters = decodeFinderCounters;

  for (int i = counters.length - 1; i > 0; i--) {
    counters[i] = counters[i - 1];
  }

  counters[0] = firstCounter;
  int value;

  @try {
    value = [self parseFinderValue:counters param1:FINDER_PATTERNS];
  }
  @catch (NotFoundException * nfe) {
    return nil;
  }
  return [[[FinderPattern alloc] init:value param1:[NSArray arrayWithObjects:start, end, nil] param2:start param3:end param4:rowNumber] autorelease];
}

- (DataCharacter *) decodeDataCharacter:(BitArray *)row pattern:(FinderPattern *)pattern isOddPattern:(BOOL)isOddPattern leftChar:(BOOL)leftChar {
  NSArray * counters = dataCharacterCounters;
  counters[0] = 0;
  counters[1] = 0;
  counters[2] = 0;
  counters[3] = 0;
  counters[4] = 0;
  counters[5] = 0;
  counters[6] = 0;
  counters[7] = 0;
  if (leftChar) {
    [self recordPatternInReverse:row param1:[pattern startEnd][0] param2:counters];
  }
   else {
    [self recordPattern:row param1:[pattern startEnd][1] + 1 param2:counters];

    for (int i = 0, j = counters.length - 1; i < j; i++, j--) {
      int temp = counters[i];
      counters[i] = counters[j];
      counters[j] = temp;
    }

  }
  int numModules = 17;
  float elementWidth = (float)[self count:counters] / (float)numModules;
  NSArray * oddCounts = oddCounts;
  NSArray * evenCounts = evenCounts;
  NSArray * oddRoundingErrors = oddRoundingErrors;
  NSArray * evenRoundingErrors = evenRoundingErrors;

  for (int i = 0; i < counters.length; i++) {
    float value = 1.0f * counters[i] / elementWidth;
    int count = (int)(value + 0.5f);
    if (count < 1) {
      count = 1;
    }
     else if (count > 8) {
      count = 8;
    }
    int offset = i >> 1;
    if ((i & 0x01) == 0) {
      oddCounts[offset] = count;
      oddRoundingErrors[offset] = value - count;
    }
     else {
      evenCounts[offset] = count;
      evenRoundingErrors[offset] = value - count;
    }
  }

  [self adjustOddEvenCounts:numModules];
  int weightRowNumber = 4 * [pattern value] + (isOddPattern ? 0 : 2) + (leftChar ? 0 : 1) - 1;
  int oddSum = 0;
  int oddChecksumPortion = 0;

  for (int i = oddCounts.length - 1; i >= 0; i--) {
    if ([self isNotA1left:pattern isOddPattern:isOddPattern leftChar:leftChar]) {
      int weight = WEIGHTS[weightRowNumber][2 * i];
      oddChecksumPortion += oddCounts[i] * weight;
    }
    oddSum += oddCounts[i];
  }

  int evenChecksumPortion = 0;
  int evenSum = 0;

  for (int i = evenCounts.length - 1; i >= 0; i--) {
    if ([self isNotA1left:pattern isOddPattern:isOddPattern leftChar:leftChar]) {
      int weight = WEIGHTS[weightRowNumber][2 * i + 1];
      evenChecksumPortion += evenCounts[i] * weight;
    }
    evenSum += evenCounts[i];
  }

  int checksumPortion = oddChecksumPortion + evenChecksumPortion;
  if ((oddSum & 0x01) != 0 || oddSum > 13 || oddSum < 4) {
    @throw [NotFoundException notFoundInstance];
  }
  int group = (13 - oddSum) / 2;
  int oddWidest = SYMBOL_WIDEST[group];
  int evenWidest = 9 - oddWidest;
  int vOdd = [RSSUtils getRSSvalue:oddCounts param1:oddWidest param2:YES];
  int vEven = [RSSUtils getRSSvalue:evenCounts param1:evenWidest param2:NO];
  int tEven = EVEN_TOTAL_SUBSET[group];
  int gSum = GSUM[group];
  int value = vOdd * tEven + vEven + gSum;
  return [[[DataCharacter alloc] init:value param1:checksumPortion] autorelease];
}

+ (BOOL) isNotA1left:(FinderPattern *)pattern isOddPattern:(BOOL)isOddPattern leftChar:(BOOL)leftChar {
  return !([pattern value] == 0 && isOddPattern && leftChar);
}

- (void) adjustOddEvenCounts:(int)numModules {
  int oddSum = [self count:oddCounts];
  int evenSum = [self count:evenCounts];
  int mismatch = oddSum + evenSum - numModules;
  BOOL oddParityBad = (oddSum & 0x01) == 1;
  BOOL evenParityBad = (evenSum & 0x01) == 0;
  BOOL incrementOdd = NO;
  BOOL decrementOdd = NO;
  if (oddSum > 13) {
    decrementOdd = YES;
  }
   else if (oddSum < 4) {
    incrementOdd = YES;
  }
  BOOL incrementEven = NO;
  BOOL decrementEven = NO;
  if (evenSum > 13) {
    decrementEven = YES;
  }
   else if (evenSum < 4) {
    incrementEven = YES;
  }
  if (mismatch == 1) {
    if (oddParityBad) {
      if (evenParityBad) {
        @throw [NotFoundException notFoundInstance];
      }
      decrementOdd = YES;
    }
     else {
      if (!evenParityBad) {
        @throw [NotFoundException notFoundInstance];
      }
      decrementEven = YES;
    }
  }
   else if (mismatch == -1) {
    if (oddParityBad) {
      if (evenParityBad) {
        @throw [NotFoundException notFoundInstance];
      }
      incrementOdd = YES;
    }
     else {
      if (!evenParityBad) {
        @throw [NotFoundException notFoundInstance];
      }
      incrementEven = YES;
    }
  }
   else if (mismatch == 0) {
    if (oddParityBad) {
      if (!evenParityBad) {
        @throw [NotFoundException notFoundInstance];
      }
      if (oddSum < evenSum) {
        incrementOdd = YES;
        decrementEven = YES;
      }
       else {
        decrementOdd = YES;
        incrementEven = YES;
      }
    }
     else {
      if (evenParityBad) {
        @throw [NotFoundException notFoundInstance];
      }
    }
  }
   else {
    @throw [NotFoundException notFoundInstance];
  }
  if (incrementOdd) {
    if (decrementOdd) {
      @throw [NotFoundException notFoundInstance];
    }
    [self increment:oddCounts param1:oddRoundingErrors];
  }
  if (decrementOdd) {
    [self decrement:oddCounts param1:oddRoundingErrors];
  }
  if (incrementEven) {
    if (decrementEven) {
      @throw [NotFoundException notFoundInstance];
    }
    [self increment:evenCounts param1:oddRoundingErrors];
  }
  if (decrementEven) {
    [self decrement:evenCounts param1:evenRoundingErrors];
  }
}

- (void) dealloc {
  [pairs release];
  [startEnd release];
  [currentSequence release];
  [super dealloc];
}

@end
