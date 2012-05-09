#import "ZXAbstractExpandedDecoder.h"
#import "ZXBitArray.h"
#import "ZXBitArrayBuilder.h"
#import "ZXDataCharacter.h"
#import "ZXExpandedPair.h"
#import "ZXResult.h"
#import "ZXRSSExpandedReader.h"
#import "ZXRSSFinderPattern.h"
#import "ZXRSSUtils.h"

const int SYMBOL_WIDEST[5] = {7, 5, 4, 3, 1};
const int EVEN_TOTAL_SUBSET[5] = {4, 20, 52, 104, 204};
const int GSUM[5] = {0, 348, 1388, 2948, 3988};

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

@interface ZXRSSExpandedReader () {
  int startEnd[2];
  int currentSequence[LONGEST_SEQUENCE_SIZE];
}

@property (nonatomic, retain) NSMutableArray *pairs;

- (void)adjustOddEvenCounts:(int)numModules;
- (ZXResult *)constructResult:(NSMutableArray *)pairs;
- (BOOL)checkChecksum;
- (BOOL)checkPairSequence:(NSMutableArray *)previousPairs pattern:(ZXRSSFinderPattern *)pattern;
- (ZXDataCharacter *)decodeDataCharacter:(ZXBitArray *)row pattern:(ZXRSSFinderPattern *)pattern isOddPattern:(BOOL)isOddPattern leftChar:(BOOL)leftChar;
- (void)findNextPair:(ZXBitArray *)row previousPairs:(NSMutableArray *)previousPairs forcedOffset:(int)forcedOffset;
- (int)nextSecondBar:(ZXBitArray *)row initialPos:(int)initialPos;
- (BOOL)isNotA1left:(ZXRSSFinderPattern *)pattern isOddPattern:(BOOL)isOddPattern leftChar:(BOOL)leftChar;
- (ZXRSSFinderPattern *)parseFoundFinderPattern:(ZXBitArray *)row rowNumber:(int)rowNumber oddPattern:(BOOL)oddPattern;
- (void)reverseCounters:(int*)counters length:(unsigned int)length;

@end

@implementation ZXRSSExpandedReader

@synthesize pairs;

- (id)init {
  if (self = [super init]) {
    self.pairs = [NSMutableArray array];
  }

  return self;
}

- (void)dealloc {
  [pairs release];

  [super dealloc];
}

- (ZXResult *)decodeRow:(int)rowNumber row:(ZXBitArray *)row hints:(NSMutableDictionary *)hints {
  [self reset];
  [self decodeRow2pairs:rowNumber row:row];
  return [self constructResult:self.pairs];
}

- (void)reset {
  [self.pairs removeAllObjects];
}

- (NSMutableArray *)decodeRow2pairs:(int)rowNumber row:(ZXBitArray *)row {
  while (YES) {
    ZXExpandedPair * nextPair = [self retrieveNextPair:row previousPairs:self.pairs rowNumber:rowNumber];
    [self.pairs addObject:nextPair];
    if ([nextPair mayBeLast]) {
      if ([self checkChecksum]) {
        return self.pairs;
      }
      if (nextPair.mustBeLast) {
        @throw [ZXNotFoundException notFoundInstance];
      }
    }
  }
}

- (ZXResult *)constructResult:(NSMutableArray *)_pairs {
  ZXBitArray * binary = [ZXBitArrayBuilder buildBitArray:_pairs];
  ZXAbstractExpandedDecoder * decoder = [ZXAbstractExpandedDecoder createDecoder:binary];
  NSString * resultingString = [decoder parseInformation];
  NSArray * firstPoints = [[((ZXExpandedPair *)[_pairs objectAtIndex:0]) finderPattern] resultPoints];
  NSArray * lastPoints = [[((ZXExpandedPair *)[_pairs lastObject]) finderPattern] resultPoints];
  return [[[ZXResult alloc] initWithText:resultingString
                                rawBytes:NULL
                                  length:0
                            resultPoints:[NSArray arrayWithObjects:[firstPoints objectAtIndex:0], [firstPoints objectAtIndex:1], [lastPoints objectAtIndex:0], [lastPoints objectAtIndex:1], nil]
                                  format:kBarcodeFormatRSSExpanded] autorelease];
}

- (BOOL)checkChecksum {
  ZXExpandedPair * firstPair = (ZXExpandedPair *)[pairs objectAtIndex:0];
  ZXDataCharacter * checkCharacter = firstPair.leftChar;
  ZXDataCharacter * firstCharacter = firstPair.rightChar;
  int checksum = [firstCharacter checksumPortion];
  int S = 2;

  for (ZXExpandedPair *currentPair in pairs) {
    checksum += currentPair.leftChar.checksumPortion;
    S++;
    if (currentPair.rightChar != nil) {
      checksum += currentPair.rightChar.checksumPortion;
      S++;
    }
  }

  checksum %= 211;
  int checkCharacterValue = 211 * (S - 4) + checksum;
  return checkCharacterValue == checkCharacter.value;
}

- (int)nextSecondBar:(ZXBitArray *)row initialPos:(int)initialPos {
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

- (ZXExpandedPair *)retrieveNextPair:(ZXBitArray *)row previousPairs:(NSMutableArray *)previousPairs rowNumber:(int)rowNumber {
  BOOL isOddPattern = [previousPairs count] % 2 == 0;
  ZXRSSFinderPattern * pattern;
  BOOL keepFinding = YES;
  int forcedOffset = -1;

  do {
    [self findNextPair:row previousPairs:previousPairs forcedOffset:forcedOffset];
    pattern = [self parseFoundFinderPattern:row rowNumber:rowNumber oddPattern:isOddPattern];
    if (pattern == nil) {
      forcedOffset = [self nextSecondBar:row initialPos:startEnd[0]];
    } else {
      keepFinding = NO;
    }
  } while (keepFinding);
  BOOL mayBeLast = [self checkPairSequence:previousPairs pattern:pattern];
  ZXDataCharacter * leftChar = [self decodeDataCharacter:row pattern:pattern isOddPattern:isOddPattern leftChar:YES];
  ZXDataCharacter * rightChar;

  @try {
    rightChar = [self decodeDataCharacter:row pattern:pattern isOddPattern:isOddPattern leftChar:NO];
  } @catch (ZXNotFoundException * nfe) {
    if (mayBeLast) {
      rightChar = nil;
    }
     else {
      @throw nfe;
    }
  }
  return [[[ZXExpandedPair alloc] initWithLeftChar:leftChar rightChar:rightChar finderPattern:pattern mayBeLast:mayBeLast] autorelease];
}

- (BOOL)checkPairSequence:(NSMutableArray *)previousPairs pattern:(ZXRSSFinderPattern *)pattern {
  int currentSequenceLength = [previousPairs count] + 1;
  if (currentSequenceLength > LONGEST_SEQUENCE_SIZE) {
    @throw [ZXNotFoundException notFoundInstance];
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

  @throw [ZXNotFoundException notFoundInstance];
}

- (void)findNextPair:(ZXBitArray *)row previousPairs:(NSMutableArray *)previousPairs forcedOffset:(int)forcedOffset {
  const int countersLen = 4;
  int counters[countersLen] = {0, 0, 0, 0};

  int width = [row size];

  int rowOffset;
  if (forcedOffset >= 0) {
    rowOffset = forcedOffset;
  } else if ([previousPairs count] == 0) {
    rowOffset = 0;
  } else {
    ZXExpandedPair * lastPair = (ZXExpandedPair *)[previousPairs lastObject];
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
          [self reverseCounters:counters length:countersLen];
        }

        if ([ZXAbstractRSSReader isFinderPattern:counters]) {
          startEnd[0] = patternStart;
          startEnd[1] = x;
          return;
        }

        if (searchingEvenPair) {
          [self reverseCounters:counters length:countersLen];
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
  @throw [ZXNotFoundException notFoundInstance];
}

- (void)reverseCounters:(int*)counters length:(unsigned int)length {
  for(int i = 0; i < length / 2; ++i){
    int tmp = counters[i];
    counters[i] = counters[length - i - 1];
    counters[length - i - 1] = tmp;
  }
}

- (ZXRSSFinderPattern *)parseFoundFinderPattern:(ZXBitArray *)row rowNumber:(int)rowNumber oddPattern:(BOOL)oddPattern {
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
  int countersLen = [self.decodeFinderCounters count];
  int counters[countersLen];
  for (int i = countersLen - 1; i > 0; i--) {
    counters[i] = [[self.decodeFinderCounters objectAtIndex:i - 1] intValue];
  }

  counters[0] = firstCounter;
  int value;

  @try {
    value = [ZXAbstractRSSReader parseFinderValue:counters countersSize:countersLen finderPatternType:RSS_PATTERNS_RSS_EXPANDED_PATTERNS];
  } @catch (ZXNotFoundException * nfe) {
    return nil;
  }
  return [[[ZXRSSFinderPattern alloc] initWithValue:value startEnd:[NSArray arrayWithObjects:[NSNumber numberWithInt:start], [NSNumber numberWithInt:end], nil] start:start end:end rowNumber:rowNumber] autorelease];
}

- (ZXDataCharacter *)decodeDataCharacter:(ZXBitArray *)row pattern:(ZXRSSFinderPattern *)pattern isOddPattern:(BOOL)isOddPattern leftChar:(BOOL)leftChar {
  const int countersLen = 8;
  int counters[countersLen] = {0, 0, 0, 0, 0, 0, 0, 0};
  if (leftChar) {
    [ZXOneDReader recordPatternInReverse:row start:[[[pattern startEnd] objectAtIndex:0] intValue] counters:counters countersSize:countersLen];
  } else {
    [ZXOneDReader recordPattern:row start:[[[pattern startEnd] objectAtIndex:1] intValue] + 1 counters:counters countersSize:countersLen];

    for (int i = 0, j = countersLen - 1; i < j; i++, j--) {
      int temp = counters[i];
      counters[i] = counters[j];
      counters[j] = temp;
    }
  }
  int numModules = 17;
  float elementWidth = (float)[ZXAbstractRSSReader count:counters] / (float)numModules;
  NSMutableArray * _oddCounts = [NSMutableArray arrayWithArray:self.oddCounts];
  NSMutableArray * _evenCounts = [NSMutableArray arrayWithArray:self.evenCounts];
  NSMutableArray * _oddRoundingErrors = [NSMutableArray arrayWithArray:self.oddRoundingErrors];
  NSMutableArray * _evenRoundingErrors = [NSMutableArray arrayWithArray:self.evenRoundingErrors];

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
    @throw [ZXNotFoundException notFoundInstance];
  }
  int group = (13 - oddSum) / 2;
  int oddWidest = SYMBOL_WIDEST[group];
  int evenWidest = 9 - oddWidest;
  int vOdd = [ZXRSSUtils rssValue:_oddCounts maxWidth:oddWidest noNarrow:YES];
  int vEven = [ZXRSSUtils rssValue:_evenCounts maxWidth:evenWidest noNarrow:NO];
  int tEven = EVEN_TOTAL_SUBSET[group];
  int gSum = GSUM[group];
  int value = vOdd * tEven + vEven + gSum;
  return [[[ZXDataCharacter alloc] initWithValue:value checksumPortion:checksumPortion] autorelease];
}

- (BOOL)isNotA1left:(ZXRSSFinderPattern *)pattern isOddPattern:(BOOL)isOddPattern leftChar:(BOOL)leftChar {
  return !([pattern value] == 0 && isOddPattern && leftChar);
}

- (void)adjustOddEvenCounts:(int)numModules {
  int oddSum = [ZXAbstractRSSReader countArray:self.oddCounts];
  int evenSum = [ZXAbstractRSSReader countArray:self.evenCounts];
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
        @throw [ZXNotFoundException notFoundInstance];
      }
      decrementOdd = YES;
    } else {
      if (!evenParityBad) {
        @throw [ZXNotFoundException notFoundInstance];
      }
      decrementEven = YES;
    }
  } else if (mismatch == -1) {
    if (oddParityBad) {
      if (evenParityBad) {
        @throw [ZXNotFoundException notFoundInstance];
      }
      incrementOdd = YES;
    } else {
      if (!evenParityBad) {
        @throw [ZXNotFoundException notFoundInstance];
      }
      incrementEven = YES;
    }
  } else if (mismatch == 0) {
    if (oddParityBad) {
      if (!evenParityBad) {
        @throw [ZXNotFoundException notFoundInstance];
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
        @throw [ZXNotFoundException notFoundInstance];
      }
    }
  } else {
    @throw [ZXNotFoundException notFoundInstance];
  }

  if (incrementOdd) {
    if (decrementOdd) {
      @throw [ZXNotFoundException notFoundInstance];
    }
    [ZXAbstractRSSReader increment:self.oddCounts errors:self.oddRoundingErrors];
  }
  if (decrementOdd) {
    [ZXAbstractRSSReader decrement:self.oddCounts errors:self.oddRoundingErrors];
  }
  if (incrementEven) {
    if (decrementEven) {
      @throw [ZXNotFoundException notFoundInstance];
    }
    [ZXAbstractRSSReader increment:self.evenCounts errors:self.oddRoundingErrors];
  }
  if (decrementEven) {
    [ZXAbstractRSSReader decrement:self.evenCounts errors:self.evenRoundingErrors];
  }
}

@end
