#import "RSS14Reader.h"

NSArray * const OUTSIDE_EVEN_TOTAL_SUBSET = [NSArray arrayWithObjects:1, 10, 34, 70, 126, nil];
NSArray * const INSIDE_ODD_TOTAL_SUBSET = [NSArray arrayWithObjects:4, 20, 48, 81, nil];
NSArray * const OUTSIDE_GSUM = [NSArray arrayWithObjects:0, 161, 961, 2015, 2715, nil];
NSArray * const INSIDE_GSUM = [NSArray arrayWithObjects:0, 336, 1036, 1516, nil];
NSArray * const OUTSIDE_ODD_WIDEST = [NSArray arrayWithObjects:8, 6, 4, 3, 1, nil];
NSArray * const INSIDE_ODD_WIDEST = [NSArray arrayWithObjects:2, 4, 6, 8, nil];
NSArray * const FINDER_PATTERNS = [NSArray arrayWithObjects:[NSArray arrayWithObjects:3, 8, 2, 1, nil], [NSArray arrayWithObjects:3, 5, 5, 1, nil], [NSArray arrayWithObjects:3, 3, 7, 1, nil], [NSArray arrayWithObjects:3, 1, 9, 1, nil], [NSArray arrayWithObjects:2, 7, 4, 1, nil], [NSArray arrayWithObjects:2, 5, 6, 1, nil], [NSArray arrayWithObjects:2, 3, 8, 1, nil], [NSArray arrayWithObjects:1, 5, 7, 1, nil], [NSArray arrayWithObjects:1, 3, 9, 1, nil], nil];

@implementation RSS14Reader

- (id) init {
  if (self = [super init]) {
    possibleLeftPairs = [[[NSMutableArray alloc] init] autorelease];
    possibleRightPairs = [[[NSMutableArray alloc] init] autorelease];
  }
  return self;
}

- (Result *) decodeRow:(int)rowNumber row:(BitArray *)row hints:(NSMutableDictionary *)hints {
  Pair * leftPair = [self decodePair:row right:NO rowNumber:rowNumber hints:hints];
  [self addOrTally:possibleLeftPairs pair:leftPair];
  [row reverse];
  Pair * rightPair = [self decodePair:row right:YES rowNumber:rowNumber hints:hints];
  [self addOrTally:possibleRightPairs pair:rightPair];
  [row reverse];
  int numLeftPairs = [possibleLeftPairs count];
  int numRightPairs = [possibleRightPairs count];

  for (int l = 0; l < numLeftPairs; l++) {
    Pair * left = (Pair *)[possibleLeftPairs objectAtIndex:l];
    if ([left count] > 1) {

      for (int r = 0; r < numRightPairs; r++) {
        Pair * right = (Pair *)[possibleRightPairs objectAtIndex:r];
        if ([right count] > 1) {
          if ([self checkChecksum:left rightPair:right]) {
            return [self constructResult:left rightPair:right];
          }
        }
      }

    }
  }

  @throw [NotFoundException notFoundInstance];
}

+ (void) addOrTally:(NSMutableArray *)possiblePairs pair:(Pair *)pair {
  if (pair == nil) {
    return;
  }
  NSEnumerator * e = [possiblePairs elements];
  BOOL found = NO;

  while ([e hasMoreElements]) {
    Pair * other = (Pair *)[e nextObject];
    if ([other value] == [pair value]) {
      [other incrementCount];
      found = YES;
      break;
    }
  }

  if (!found) {
    [possiblePairs addObject:pair];
  }
}

- (void) reset {
  [possibleLeftPairs setSize:0];
  [possibleRightPairs setSize:0];
}

+ (Result *) constructResult:(Pair *)leftPair rightPair:(Pair *)rightPair {
  long symbolValue = 4537077L * [leftPair value] + [rightPair value];
  NSString * text = [String valueOf:symbolValue];
  StringBuffer * buffer = [[[StringBuffer alloc] init:14] autorelease];

  for (int i = 13 - [text length]; i > 0; i--) {
    [buffer append:'0'];
  }

  [buffer append:text];
  int checkDigit = 0;

  for (int i = 0; i < 13; i++) {
    int digit = [buffer charAt:i] - '0';
    checkDigit += (i & 0x01) == 0 ? 3 * digit : digit;
  }

  checkDigit = 10 - (checkDigit % 10);
  if (checkDigit == 10) {
    checkDigit = 0;
  }
  [buffer append:checkDigit];
  NSArray * leftPoints = [[leftPair finderPattern] resultPoints];
  NSArray * rightPoints = [[rightPair finderPattern] resultPoints];
  return [[[Result alloc] init:[String valueOf:[buffer description]] param1:nil param2:[NSArray arrayWithObjects:leftPoints[0], leftPoints[1], rightPoints[0], rightPoints[1], nil] param3:BarcodeFormat.RSS_14] autorelease];
}

+ (BOOL) checkChecksum:(Pair *)leftPair rightPair:(Pair *)rightPair {
  int leftFPValue = [[leftPair finderPattern] value];
  int rightFPValue = [[rightPair finderPattern] value];
  if ((leftFPValue == 0 && rightFPValue == 8) || (leftFPValue == 8 && rightFPValue == 0)) {
  }
  int checkValue = ([leftPair checksumPortion] + 16 * [rightPair checksumPortion]) % 79;
  int targetCheckValue = 9 * [[leftPair finderPattern] value] + [[rightPair finderPattern] value];
  if (targetCheckValue > 72) {
    targetCheckValue--;
  }
  if (targetCheckValue > 8) {
    targetCheckValue--;
  }
  return checkValue == targetCheckValue;
}

- (Pair *) decodePair:(BitArray *)row right:(BOOL)right rowNumber:(int)rowNumber hints:(NSMutableDictionary *)hints {

  @try {
    NSArray * startEnd = [self findFinderPattern:row rowOffset:0 rightFinderPattern:right];
    FinderPattern * pattern = [self parseFoundFinderPattern:row rowNumber:rowNumber right:right startEnd:startEnd];
    ResultPointCallback * resultPointCallback = hints == nil ? nil : (ResultPointCallback *)[hints objectForKey:DecodeHintType.NEED_RESULT_POINT_CALLBACK];
    if (resultPointCallback != nil) {
      float center = (startEnd[0] + startEnd[1]) / 2.0f;
      if (right) {
        center = [row size] - 1 - center;
      }
      [resultPointCallback foundPossibleResultPoint:[[[ResultPoint alloc] init:center param1:rowNumber] autorelease]];
    }
    DataCharacter * outside = [self decodeDataCharacter:row pattern:pattern outsideChar:YES];
    DataCharacter * inside = [self decodeDataCharacter:row pattern:pattern outsideChar:NO];
    return [[[Pair alloc] init:1597 * [outside value] + [inside value] param1:[outside checksumPortion] + 4 * [inside checksumPortion] param2:pattern] autorelease];
  }
  @catch (NotFoundException * re) {
    return nil;
  }
}

- (DataCharacter *) decodeDataCharacter:(BitArray *)row pattern:(FinderPattern *)pattern outsideChar:(BOOL)outsideChar {
  NSArray * counters = dataCharacterCounters;
  counters[0] = 0;
  counters[1] = 0;
  counters[2] = 0;
  counters[3] = 0;
  counters[4] = 0;
  counters[5] = 0;
  counters[6] = 0;
  counters[7] = 0;
  if (outsideChar) {
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
  int numModules = outsideChar ? 16 : 15;
  float elementWidth = (float)[self count:counters] / (float)numModules;
  NSArray * oddCounts = oddCounts;
  NSArray * evenCounts = evenCounts;
  NSArray * oddRoundingErrors = oddRoundingErrors;
  NSArray * evenRoundingErrors = evenRoundingErrors;

  for (int i = 0; i < counters.length; i++) {
    float value = (float)counters[i] / elementWidth;
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

  [self adjustOddEvenCounts:outsideChar numModules:numModules];
  int oddSum = 0;
  int oddChecksumPortion = 0;

  for (int i = oddCounts.length - 1; i >= 0; i--) {
    oddChecksumPortion *= 9;
    oddChecksumPortion += oddCounts[i];
    oddSum += oddCounts[i];
  }

  int evenChecksumPortion = 0;
  int evenSum = 0;

  for (int i = evenCounts.length - 1; i >= 0; i--) {
    evenChecksumPortion *= 9;
    evenChecksumPortion += evenCounts[i];
    evenSum += evenCounts[i];
  }

  int checksumPortion = oddChecksumPortion + 3 * evenChecksumPortion;
  if (outsideChar) {
    if ((oddSum & 0x01) != 0 || oddSum > 12 || oddSum < 4) {
      @throw [NotFoundException notFoundInstance];
    }
    int group = (12 - oddSum) / 2;
    int oddWidest = OUTSIDE_ODD_WIDEST[group];
    int evenWidest = 9 - oddWidest;
    int vOdd = [RSSUtils getRSSvalue:oddCounts param1:oddWidest param2:NO];
    int vEven = [RSSUtils getRSSvalue:evenCounts param1:evenWidest param2:YES];
    int tEven = OUTSIDE_EVEN_TOTAL_SUBSET[group];
    int gSum = OUTSIDE_GSUM[group];
    return [[[DataCharacter alloc] init:vOdd * tEven + vEven + gSum param1:checksumPortion] autorelease];
  }
   else {
    if ((evenSum & 0x01) != 0 || evenSum > 10 || evenSum < 4) {
      @throw [NotFoundException notFoundInstance];
    }
    int group = (10 - evenSum) / 2;
    int oddWidest = INSIDE_ODD_WIDEST[group];
    int evenWidest = 9 - oddWidest;
    int vOdd = [RSSUtils getRSSvalue:oddCounts param1:oddWidest param2:YES];
    int vEven = [RSSUtils getRSSvalue:evenCounts param1:evenWidest param2:NO];
    int tOdd = INSIDE_ODD_TOTAL_SUBSET[group];
    int gSum = INSIDE_GSUM[group];
    return [[[DataCharacter alloc] init:vEven * tOdd + vOdd + gSum param1:checksumPortion] autorelease];
  }
}

- (NSArray *) findFinderPattern:(BitArray *)row rowOffset:(int)rowOffset rightFinderPattern:(BOOL)rightFinderPattern {
  NSArray * counters = decodeFinderCounters;
  counters[0] = 0;
  counters[1] = 0;
  counters[2] = 0;
  counters[3] = 0;
  int width = [row size];
  BOOL isWhite = NO;

  while (rowOffset < width) {
    isWhite = ![row get:rowOffset];
    if (rightFinderPattern == isWhite) {
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
        if ([self isFinderPattern:counters]) {
          return [NSArray arrayWithObjects:patternStart, x, nil];
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

- (FinderPattern *) parseFoundFinderPattern:(BitArray *)row rowNumber:(int)rowNumber right:(BOOL)right startEnd:(NSArray *)startEnd {
  BOOL firstIsBlack = [row get:startEnd[0]];
  int firstElementStart = startEnd[0] - 1;

  while (firstElementStart >= 0 && firstIsBlack ^ [row get:firstElementStart]) {
    firstElementStart--;
  }

  firstElementStart++;
  int firstCounter = startEnd[0] - firstElementStart;
  NSArray * counters = decodeFinderCounters;

  for (int i = counters.length - 1; i > 0; i--) {
    counters[i] = counters[i - 1];
  }

  counters[0] = firstCounter;
  int value = [self parseFinderValue:counters param1:FINDER_PATTERNS];
  int start = firstElementStart;
  int end = startEnd[1];
  if (right) {
    start = [row size] - 1 - start;
    end = [row size] - 1 - end;
  }
  return [[[FinderPattern alloc] init:value param1:[NSArray arrayWithObjects:firstElementStart, startEnd[1], nil] param2:start param3:end param4:rowNumber] autorelease];
}

- (void) adjustOddEvenCounts:(BOOL)outsideChar numModules:(int)numModules {
  int oddSum = [self count:oddCounts];
  int evenSum = [self count:evenCounts];
  int mismatch = oddSum + evenSum - numModules;
  BOOL oddParityBad = (oddSum & 0x01) == (outsideChar ? 1 : 0);
  BOOL evenParityBad = (evenSum & 0x01) == 1;
  BOOL incrementOdd = NO;
  BOOL decrementOdd = NO;
  BOOL incrementEven = NO;
  BOOL decrementEven = NO;
  if (outsideChar) {
    if (oddSum > 12) {
      decrementOdd = YES;
    }
     else if (oddSum < 4) {
      incrementOdd = YES;
    }
    if (evenSum > 12) {
      decrementEven = YES;
    }
     else if (evenSum < 4) {
      incrementEven = YES;
    }
  }
   else {
    if (oddSum > 11) {
      decrementOdd = YES;
    }
     else if (oddSum < 5) {
      incrementOdd = YES;
    }
    if (evenSum > 10) {
      decrementEven = YES;
    }
     else if (evenSum < 4) {
      incrementEven = YES;
    }
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
  [possibleLeftPairs release];
  [possibleRightPairs release];
  [super dealloc];
}

@end
