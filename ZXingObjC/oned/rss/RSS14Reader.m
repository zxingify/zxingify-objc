#import "DecodeHintType.h"
#import "Pair.h"
#import "ResultPointCallback.h"
#import "RSS14Reader.h"
#import "RSSFinderPattern.h"
#import "RSSUtils.h"

const int OUTSIDE_EVEN_TOTAL_SUBSET[5] = {1,10,34,70,126};
const int INSIDE_ODD_TOTAL_SUBSET[4] = {4,20,48,81};
const int OUTSIDE_GSUM[5] = {0,161,961,2015,2715};
const int INSIDE_GSUM[4] = {0,336,1036,1516};
const int OUTSIDE_ODD_WIDEST[5] = {8,6,4,3,1};
const int INSIDE_ODD_WIDEST[4] = {2,4,6,8};

static NSMutableArray* FINDER_PATTERNS = nil;

@interface RSS14Reader ()

- (void) addOrTally:(NSMutableArray *)possiblePairs pair:(Pair *)pair;
- (void) adjustOddEvenCounts:(BOOL)outsideChar numModules:(int)numModules;
- (void) buildFinderPatterns;
- (BOOL) checkChecksum:(Pair *)leftPair rightPair:(Pair *)rightPair;
- (Result *) constructResult:(Pair *)leftPair rightPair:(Pair *)rightPair;
- (DataCharacter *) decodeDataCharacter:(BitArray *)row pattern:(RSSFinderPattern *)pattern outsideChar:(BOOL)outsideChar;
- (Pair *) decodePair:(BitArray *)row right:(BOOL)right rowNumber:(int)rowNumber hints:(NSMutableDictionary *)hints;
- (NSArray *) findFinderPattern:(BitArray *)row rowOffset:(int)rowOffset rightFinderPattern:(BOOL)rightFinderPattern;
- (RSSFinderPattern *) parseFoundFinderPattern:(BitArray *)row rowNumber:(int)rowNumber right:(BOOL)right startEnd:(NSArray *)startEnd;

@end

@implementation RSS14Reader

- (id) init {
  if (self = [super init]) {
    possibleLeftPairs = [[NSMutableArray alloc] init];
    possibleRightPairs = [[NSMutableArray alloc] init];
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

  for (Pair *left in possibleLeftPairs) {
    if ([left count] > 1) {
      for (Pair *right in possibleRightPairs) {
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

- (void) addOrTally:(NSMutableArray *)possiblePairs pair:(Pair *)pair {
  if (pair == nil) {
    return;
  }
  BOOL found = NO;
  for (Pair *other in possiblePairs) {
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

- (void)buildFinderPatterns {
  if (!FINDER_PATTERNS) {
    FINDER_PATTERNS = [[NSMutableArray alloc] initWithCapacity:9];

    [FINDER_PATTERNS addObject:[NSArray arrayWithObjects:
                                [NSNumber numberWithInt:3],
                                [NSNumber numberWithInt:8],
                                [NSNumber numberWithInt:2],
                                [NSNumber numberWithInt:1], nil]];
    
    [FINDER_PATTERNS addObject:[NSArray arrayWithObjects:
                                [NSNumber numberWithInt:3],
                                [NSNumber numberWithInt:5],
                                [NSNumber numberWithInt:5],
                                [NSNumber numberWithInt:1], nil]];
    
    [FINDER_PATTERNS addObject:[NSArray arrayWithObjects:
                                [NSNumber numberWithInt:3],
                                [NSNumber numberWithInt:3],
                                [NSNumber numberWithInt:7],
                                [NSNumber numberWithInt:1], nil]];
    
    [FINDER_PATTERNS addObject:[NSArray arrayWithObjects:
                                [NSNumber numberWithInt:3],
                                [NSNumber numberWithInt:1],
                                [NSNumber numberWithInt:9],
                                [NSNumber numberWithInt:1], nil]];
    
    [FINDER_PATTERNS addObject:[NSArray arrayWithObjects:
                                [NSNumber numberWithInt:2],
                                [NSNumber numberWithInt:7],
                                [NSNumber numberWithInt:4],
                                [NSNumber numberWithInt:1], nil]];
    
    [FINDER_PATTERNS addObject:[NSArray arrayWithObjects:
                                [NSNumber numberWithInt:2],
                                [NSNumber numberWithInt:5],
                                [NSNumber numberWithInt:6],
                                [NSNumber numberWithInt:1], nil]];
    
    [FINDER_PATTERNS addObject:[NSArray arrayWithObjects:
                                [NSNumber numberWithInt:2],
                                [NSNumber numberWithInt:3],
                                [NSNumber numberWithInt:8],
                                [NSNumber numberWithInt:1], nil]];
    
    [FINDER_PATTERNS addObject:[NSArray arrayWithObjects:
                                [NSNumber numberWithInt:1],
                                [NSNumber numberWithInt:5],
                                [NSNumber numberWithInt:7],
                                [NSNumber numberWithInt:1], nil]];
    
    [FINDER_PATTERNS addObject:[NSArray arrayWithObjects:
                                [NSNumber numberWithInt:1],
                                [NSNumber numberWithInt:3],
                                [NSNumber numberWithInt:9],
                                [NSNumber numberWithInt:1], nil]];
  }
}

- (void) reset {
  [possibleLeftPairs removeAllObjects];
  [possibleRightPairs removeAllObjects];
}

- (Result *) constructResult:(Pair *)leftPair rightPair:(Pair *)rightPair {
  long symbolValue = 4537077L * [leftPair value] + [rightPair value];
  NSString * text = [[NSNumber numberWithLong:symbolValue] stringValue];
  NSMutableString * buffer = [NSMutableString stringWithCapacity:14];

  for (int i = 13 - [text length]; i > 0; i--) {
    [buffer appendString:@"0"];
  }

  [buffer appendString:text];
  int checkDigit = 0;

  for (int i = 0; i < 13; i++) {
    int digit = [buffer characterAtIndex:i] - '0';
    checkDigit += (i & 0x01) == 0 ? 3 * digit : digit;
  }

  checkDigit = 10 - (checkDigit % 10);
  if (checkDigit == 10) {
    checkDigit = 0;
  }
  [buffer appendFormat:@"%d", checkDigit];
  NSArray * leftPoints = [[leftPair finderPattern] resultPoints];
  NSArray * rightPoints = [[rightPair finderPattern] resultPoints];
  return [[[Result alloc] init:buffer
                      rawBytes:nil
                  resultPoints:[NSArray arrayWithObjects:[leftPoints objectAtIndex:0], [leftPoints objectAtIndex:1], [rightPoints objectAtIndex:0], [rightPoints objectAtIndex:1], nil]
                        format:kBarcodeRSS14] autorelease];
}

- (BOOL) checkChecksum:(Pair *)leftPair rightPair:(Pair *)rightPair {
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
    RSSFinderPattern * pattern = [self parseFoundFinderPattern:row rowNumber:rowNumber right:right startEnd:startEnd];
    
    id<ResultPointCallback> resultPointCallback = hints == nil ? nil : (id<ResultPointCallback>)[hints objectForKey:[NSNumber numberWithInt:kDecodeHintTypeNeedResultPointCallback]];
    if (resultPointCallback != nil) {
      float center = ([[startEnd objectAtIndex:0] intValue] + [[startEnd objectAtIndex:1] intValue]) / 2.0f;
      if (right) {
        center = [row size] - 1 - center;
      }
      [resultPointCallback foundPossibleResultPoint:[[[ResultPoint alloc] initWithX:center y:rowNumber] autorelease]];
    }
    DataCharacter * outside = [self decodeDataCharacter:row pattern:pattern outsideChar:YES];
    DataCharacter * inside = [self decodeDataCharacter:row pattern:pattern outsideChar:NO];
    return [[[Pair alloc] initWithValue:1597 * [outside value] + [inside value]
                                 checksumPortion:[outside checksumPortion] + 4 * [inside checksumPortion]
                                 finderPattern:pattern] autorelease];
  }
  @catch (NotFoundException * re) {
    return nil;
  }
}

- (DataCharacter *) decodeDataCharacter:(BitArray *)row pattern:(RSSFinderPattern *)pattern outsideChar:(BOOL)outsideChar {
  NSMutableArray * counters = [NSMutableArray arrayWithArray:dataCharacterCounters];
  
  while ([counters count] < 8) {
    [counters addObject:[NSNull null]];
  }
  
  [counters replaceObjectAtIndex:0 withObject:[NSNumber numberWithInt:0]];
  [counters replaceObjectAtIndex:1 withObject:[NSNumber numberWithInt:0]];
  [counters replaceObjectAtIndex:2 withObject:[NSNumber numberWithInt:0]];
  [counters replaceObjectAtIndex:3 withObject:[NSNumber numberWithInt:0]];
  [counters replaceObjectAtIndex:4 withObject:[NSNumber numberWithInt:0]];
  [counters replaceObjectAtIndex:5 withObject:[NSNumber numberWithInt:0]];
  [counters replaceObjectAtIndex:6 withObject:[NSNumber numberWithInt:0]];
  [counters replaceObjectAtIndex:7 withObject:[NSNumber numberWithInt:0]];

  if (outsideChar) {
    [OneDReader recordPatternInReverse:row start:[[[pattern startEnd] objectAtIndex:0] intValue] counters:counters];
  } else {
    [OneDReader recordPattern:row start:[[[pattern startEnd] objectAtIndex:1] intValue] counters:counters];

    for (int i = 0, j = [counters count] - 1; i < j; i++, j--) {
      id temp = [counters objectAtIndex:i];
      [counters replaceObjectAtIndex:i withObject:[counters objectAtIndex:j]];
      [counters replaceObjectAtIndex:j withObject:temp];
    }

  }
  int numModules = outsideChar ? 16 : 15;
  float elementWidth = (float)[AbstractRSSReader count:counters] / (float)numModules;
  NSMutableArray * _oddCounts = [NSMutableArray arrayWithArray:oddCounts];
  NSMutableArray * _evenCounts = [NSMutableArray arrayWithArray:evenCounts];
  NSMutableArray * _oddRoundingErrors = [NSMutableArray arrayWithArray:oddRoundingErrors];
  NSMutableArray * _evenRoundingErrors = [NSMutableArray arrayWithArray:evenRoundingErrors];

  for (int i = 0; i < [counters count]; i++) {
    float value = [[counters objectAtIndex:i] floatValue] / elementWidth;
    int count = (int)(value + 0.5f);
    if (count < 1) {
      count = 1;
    }
     else if (count > 8) {
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

  [self adjustOddEvenCounts:outsideChar numModules:numModules];
  int oddSum = 0;
  int oddChecksumPortion = 0;

  for (int i = [_oddCounts count] - 1; i >= 0; i--) {
    oddChecksumPortion *= 9;
    oddChecksumPortion += [[_oddCounts objectAtIndex:i] intValue];
    oddSum += [[_oddCounts objectAtIndex:i] intValue];
  }

  int evenChecksumPortion = 0;
  int evenSum = 0;

  for (int i = [_evenCounts count] - 1; i >= 0; i--) {
    evenChecksumPortion *= 9;
    evenChecksumPortion += [[_evenCounts objectAtIndex:i] intValue];
    evenSum += [[_evenCounts objectAtIndex:i] intValue];
  }

  int checksumPortion = oddChecksumPortion + 3 * evenChecksumPortion;
  if (outsideChar) {
    if ((oddSum & 0x01) != 0 || oddSum > 12 || oddSum < 4) {
      @throw [NotFoundException notFoundInstance];
    }
    int group = (12 - oddSum) / 2;
    int oddWidest = OUTSIDE_ODD_WIDEST[group];
    int evenWidest = 9 - oddWidest;
    int vOdd = [RSSUtils getRSSvalue:_oddCounts maxWidth:oddWidest noNarrow:NO];
    int vEven = [RSSUtils getRSSvalue:_evenCounts maxWidth:evenWidest noNarrow:YES];
    int tEven = OUTSIDE_EVEN_TOTAL_SUBSET[group];
    int gSum = OUTSIDE_GSUM[group];
    return [[[DataCharacter alloc] init:vOdd * tEven + vEven + gSum checksumPortion:checksumPortion] autorelease];
  } else {
    if ((evenSum & 0x01) != 0 || evenSum > 10 || evenSum < 4) {
      @throw [NotFoundException notFoundInstance];
    }
    int group = (10 - evenSum) / 2;
    int oddWidest = INSIDE_ODD_WIDEST[group];
    int evenWidest = 9 - oddWidest;
    int vOdd = [RSSUtils getRSSvalue:_oddCounts maxWidth:oddWidest noNarrow:YES];
    int vEven = [RSSUtils getRSSvalue:_evenCounts maxWidth:evenWidest noNarrow:NO];
    int tOdd = INSIDE_ODD_TOTAL_SUBSET[group];
    int gSum = INSIDE_GSUM[group];
    return [[[DataCharacter alloc] init:vEven * tOdd + vOdd + gSum checksumPortion:checksumPortion] autorelease];
  }
}

- (NSArray *) findFinderPattern:(BitArray *)row rowOffset:(int)rowOffset rightFinderPattern:(BOOL)rightFinderPattern {
  NSMutableArray * counters = [NSMutableArray arrayWithArray:decodeFinderCounters];
  
  while ([counters count] < 4) {
    [counters addObject:[NSNull null]];
  }
  
  [counters replaceObjectAtIndex:0 withObject:[NSNumber numberWithInt:0]];
  [counters replaceObjectAtIndex:1 withObject:[NSNumber numberWithInt:0]];
  [counters replaceObjectAtIndex:2 withObject:[NSNumber numberWithInt:0]];
  [counters replaceObjectAtIndex:3 withObject:[NSNumber numberWithInt:0]];

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
      [counters replaceObjectAtIndex:counterPosition
                          withObject:[NSNumber numberWithInt:[[counters objectAtIndex:counterPosition] intValue] + 1]];
    } else {
      if (counterPosition == 3) {
        if ([AbstractRSSReader isFinderPattern:counters]) {
          return [NSArray arrayWithObjects:[NSNumber numberWithInt:patternStart], [NSNumber numberWithInt:x], nil];
        }
        patternStart += [[counters objectAtIndex:0] intValue] + [[counters objectAtIndex:1] intValue];
        [counters replaceObjectAtIndex:0 withObject:[counters objectAtIndex:2]];
        [counters replaceObjectAtIndex:1 withObject:[counters objectAtIndex:3]];
        [counters replaceObjectAtIndex:2 withObject:[NSNumber numberWithInt:0]];
        [counters replaceObjectAtIndex:3 withObject:[NSNumber numberWithInt:0]];
        counterPosition--;
      } else {
        counterPosition++;
      }
      [counters replaceObjectAtIndex:counterPosition withObject:[NSNumber numberWithInt:1]];
      isWhite = !isWhite;
    }
  }

  @throw [NotFoundException notFoundInstance];
}

- (RSSFinderPattern *) parseFoundFinderPattern:(BitArray *)row rowNumber:(int)rowNumber right:(BOOL)right startEnd:(NSArray *)startEnd {
  BOOL firstIsBlack = [row get:[[startEnd objectAtIndex:0] intValue]];
  int firstElementStart = [[startEnd objectAtIndex:0] intValue] - 1;

  while (firstElementStart >= 0 && firstIsBlack ^ [row get:firstElementStart]) {
    firstElementStart--;
  }

  firstElementStart++;
  int firstCounter = [[startEnd objectAtIndex:0] intValue] - firstElementStart;
  NSMutableArray * counters = [NSMutableArray arrayWithArray:decodeFinderCounters];

  for (int i = [counters count] - 1; i > 0; i--) {
    [counters replaceObjectAtIndex:i withObject:[counters objectAtIndex:i - 1]];
  }

  [counters replaceObjectAtIndex:0 withObject:[NSNumber numberWithInt:firstCounter]];
  
  if (!FINDER_PATTERNS) {
    [self buildFinderPatterns];
  }
  int value = [AbstractRSSReader parseFinderValue:counters finderPatterns:FINDER_PATTERNS];
  int start = firstElementStart;
  int end = [[startEnd objectAtIndex:1] intValue];
  if (right) {
    start = [row size] - 1 - start;
    end = [row size] - 1 - end;
  }
  return [[[RSSFinderPattern alloc] initWithValue:value
                                         startEnd:[NSArray arrayWithObjects:[NSNumber numberWithInt:firstElementStart], [startEnd objectAtIndex:1], nil] 
                                           start:start end:end rowNumber:rowNumber] autorelease];
}

- (void) adjustOddEvenCounts:(BOOL)outsideChar numModules:(int)numModules {
  int oddSum = [AbstractRSSReader count:oddCounts];
  int evenSum = [AbstractRSSReader count:evenCounts];
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
    } else if (oddSum < 4) {
      incrementOdd = YES;
    }
    if (evenSum > 12) {
      decrementEven = YES;
    } else if (evenSum < 4) {
      incrementEven = YES;
    }
  } else {
    if (oddSum > 11) {
      decrementOdd = YES;
    } else if (oddSum < 5) {
      incrementOdd = YES;
    }
    if (evenSum > 10) {
      decrementEven = YES;
    } else if (evenSum < 4) {
      incrementEven = YES;
    }
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
  [possibleLeftPairs release];
  [possibleRightPairs release];
  [super dealloc];
}

@end
