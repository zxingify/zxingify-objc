#import "ZXBarcodeFormat.h"
#import "ZXDecodeHintType.h"
#import "ZXPair.h"
#import "ZXResultPointCallback.h"
#import "ZXRSS14Reader.h"
#import "ZXRSSFinderPattern.h"
#import "ZXRSSUtils.h"

const int OUTSIDE_EVEN_TOTAL_SUBSET[5] = {1,10,34,70,126};
const int INSIDE_ODD_TOTAL_SUBSET[4] = {4,20,48,81};
const int OUTSIDE_GSUM[5] = {0,161,961,2015,2715};
const int INSIDE_GSUM[4] = {0,336,1036,1516};
const int OUTSIDE_ODD_WIDEST[5] = {8,6,4,3,1};
const int INSIDE_ODD_WIDEST[4] = {2,4,6,8};

@interface ZXRSS14Reader ()

- (void) addOrTally:(NSMutableArray *)possiblePairs pair:(ZXPair *)pair;
- (void) adjustOddEvenCounts:(BOOL)outsideChar numModules:(int)numModules;
- (BOOL) checkChecksum:(ZXPair *)leftPair rightPair:(ZXPair *)rightPair;
- (ZXResult *) constructResult:(ZXPair *)leftPair rightPair:(ZXPair *)rightPair;
- (ZXDataCharacter *) decodeDataCharacter:(ZXBitArray *)row pattern:(ZXRSSFinderPattern *)pattern outsideChar:(BOOL)outsideChar;
- (ZXPair *) decodePair:(ZXBitArray *)row right:(BOOL)right rowNumber:(int)rowNumber hints:(NSMutableDictionary *)hints;
- (NSArray *) findFinderPattern:(ZXBitArray *)row rowOffset:(int)rowOffset rightFinderPattern:(BOOL)rightFinderPattern;
- (ZXRSSFinderPattern *) parseFoundFinderPattern:(ZXBitArray *)row rowNumber:(int)rowNumber right:(BOOL)right startEnd:(NSArray *)startEnd;

@end

@implementation ZXRSS14Reader

- (id) init {
  if (self = [super init]) {
    possibleLeftPairs = [[NSMutableArray alloc] init];
    possibleRightPairs = [[NSMutableArray alloc] init];
  }
  return self;
}

- (ZXResult *) decodeRow:(int)rowNumber row:(ZXBitArray *)row hints:(NSMutableDictionary *)hints {
  ZXPair * leftPair = [self decodePair:row right:NO rowNumber:rowNumber hints:hints];
  [self addOrTally:possibleLeftPairs pair:leftPair];
  [row reverse];
  ZXPair * rightPair = [self decodePair:row right:YES rowNumber:rowNumber hints:hints];
  [self addOrTally:possibleRightPairs pair:rightPair];
  [row reverse];

  for (ZXPair *left in possibleLeftPairs) {
    if ([left count] > 1) {
      for (ZXPair *right in possibleRightPairs) {
        if ([right count] > 1) {
          if ([self checkChecksum:left rightPair:right]) {
            return [self constructResult:left rightPair:right];
          }
        }
      }

    }
  }

  @throw [ZXNotFoundException notFoundInstance];
}

- (void) addOrTally:(NSMutableArray *)possiblePairs pair:(ZXPair *)pair {
  if (pair == nil) {
    return;
  }
  BOOL found = NO;
  for (ZXPair *other in possiblePairs) {
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
  [possibleLeftPairs removeAllObjects];
  [possibleRightPairs removeAllObjects];
}

- (ZXResult *) constructResult:(ZXPair *)leftPair rightPair:(ZXPair *)rightPair {
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
  return [[[ZXResult alloc] initWithText:buffer
                              rawBytes:nil
                                length:0
                          resultPoints:[NSArray arrayWithObjects:[leftPoints objectAtIndex:0], [leftPoints objectAtIndex:1], [rightPoints objectAtIndex:0], [rightPoints objectAtIndex:1], nil]
                                format:kBarcodeFormatRSS14] autorelease];
}

- (BOOL) checkChecksum:(ZXPair *)leftPair rightPair:(ZXPair *)rightPair {
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

- (ZXPair *) decodePair:(ZXBitArray *)row right:(BOOL)right rowNumber:(int)rowNumber hints:(NSMutableDictionary *)hints {

  @try {
    NSArray * startEnd = [self findFinderPattern:row rowOffset:0 rightFinderPattern:right];
    ZXRSSFinderPattern * pattern = [self parseFoundFinderPattern:row rowNumber:rowNumber right:right startEnd:startEnd];
    
    id<ZXResultPointCallback> resultPointCallback = hints == nil ? nil : (id<ZXResultPointCallback>)[hints objectForKey:[NSNumber numberWithInt:kDecodeHintTypeNeedResultPointCallback]];
    if (resultPointCallback != nil) {
      float center = ([[startEnd objectAtIndex:0] intValue] + [[startEnd objectAtIndex:1] intValue]) / 2.0f;
      if (right) {
        center = [row size] - 1 - center;
      }
      [resultPointCallback foundPossibleResultPoint:[[[ZXResultPoint alloc] initWithX:center y:rowNumber] autorelease]];
    }
    ZXDataCharacter * outside = [self decodeDataCharacter:row pattern:pattern outsideChar:YES];
    ZXDataCharacter * inside = [self decodeDataCharacter:row pattern:pattern outsideChar:NO];
    return [[[ZXPair alloc] initWithValue:1597 * [outside value] + [inside value]
                                 checksumPortion:[outside checksumPortion] + 4 * [inside checksumPortion]
                                 finderPattern:pattern] autorelease];
  }
  @catch (ZXNotFoundException * re) {
    return nil;
  }
}

- (ZXDataCharacter *) decodeDataCharacter:(ZXBitArray *)row pattern:(ZXRSSFinderPattern *)pattern outsideChar:(BOOL)outsideChar {
  int countersLen = [dataCharacterCounters count];
  int counters[countersLen];
  for (int i = 0; i < countersLen; i++) {
    counters[i] = 0;
  }

  if (outsideChar) {
    [ZXOneDReader recordPatternInReverse:row start:[[[pattern startEnd] objectAtIndex:0] intValue] counters:counters countersSize:countersLen];
  } else {
    [ZXOneDReader recordPattern:row start:[[[pattern startEnd] objectAtIndex:1] intValue] counters:counters countersSize:countersLen];

    for (int i = 0, j = (sizeof(counters) / sizeof(int)) - 1; i < j; i++, j--) {
      int temp = counters[i];
      counters[i] = counters[j];
      counters[j] = temp;
    }
  }

  int numModules = outsideChar ? 16 : 15;
  float elementWidth = (float)[ZXAbstractRSSReader count:counters] / (float)numModules;

  NSMutableArray * _oddCounts = [NSMutableArray arrayWithArray:oddCounts];
  NSMutableArray * _evenCounts = [NSMutableArray arrayWithArray:evenCounts];
  NSMutableArray * _oddRoundingErrors = [NSMutableArray arrayWithArray:oddRoundingErrors];
  NSMutableArray * _evenRoundingErrors = [NSMutableArray arrayWithArray:evenRoundingErrors];

  for (int i = 0; i < sizeof(counters) / sizeof(int); i++) {
    float value = (float) counters[i] / elementWidth;
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
      @throw [ZXNotFoundException notFoundInstance];
    }
    int group = (12 - oddSum) / 2;
    int oddWidest = OUTSIDE_ODD_WIDEST[group];
    int evenWidest = 9 - oddWidest;
    int vOdd = [ZXRSSUtils getRSSvalue:_oddCounts maxWidth:oddWidest noNarrow:NO];
    int vEven = [ZXRSSUtils getRSSvalue:_evenCounts maxWidth:evenWidest noNarrow:YES];
    int tEven = OUTSIDE_EVEN_TOTAL_SUBSET[group];
    int gSum = OUTSIDE_GSUM[group];
    return [[[ZXDataCharacter alloc] initWithValue:vOdd * tEven + vEven + gSum checksumPortion:checksumPortion] autorelease];
  } else {
    if ((evenSum & 0x01) != 0 || evenSum > 10 || evenSum < 4) {
      @throw [ZXNotFoundException notFoundInstance];
    }
    int group = (10 - evenSum) / 2;
    int oddWidest = INSIDE_ODD_WIDEST[group];
    int evenWidest = 9 - oddWidest;
    int vOdd = [ZXRSSUtils getRSSvalue:_oddCounts maxWidth:oddWidest noNarrow:YES];
    int vEven = [ZXRSSUtils getRSSvalue:_evenCounts maxWidth:evenWidest noNarrow:NO];
    int tOdd = INSIDE_ODD_TOTAL_SUBSET[group];
    int gSum = INSIDE_GSUM[group];
    return [[[ZXDataCharacter alloc] initWithValue:vEven * tOdd + vOdd + gSum checksumPortion:checksumPortion] autorelease];
  }
}

- (NSArray *) findFinderPattern:(ZXBitArray *)row rowOffset:(int)rowOffset rightFinderPattern:(BOOL)rightFinderPattern {
  int counters[[decodeFinderCounters count]];
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
    } else {
      if (counterPosition == 3) {
        if ([ZXAbstractRSSReader isFinderPattern:counters]) {
          return [NSArray arrayWithObjects:[NSNumber numberWithInt:patternStart], [NSNumber numberWithInt:x], nil];
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

- (ZXRSSFinderPattern *) parseFoundFinderPattern:(ZXBitArray *)row rowNumber:(int)rowNumber right:(BOOL)right startEnd:(NSArray *)startEnd {
  BOOL firstIsBlack = [row get:[[startEnd objectAtIndex:0] intValue]];
  int firstElementStart = [[startEnd objectAtIndex:0] intValue] - 1;

  while (firstElementStart >= 0 && firstIsBlack ^ [row get:firstElementStart]) {
    firstElementStart--;
  }

  firstElementStart++;
  int firstCounter = [[startEnd objectAtIndex:0] intValue] - firstElementStart;

  int countersLen = [decodeFinderCounters count];
  int counters[countersLen];
  for (int i = 0; i < countersLen; i++) {
    counters[i] = [[decodeFinderCounters objectAtIndex:i] intValue];
  }
  
  for (int i = (sizeof(counters) / sizeof(int)) - 1; i > 0; i--) {
    counters[i] = counters[i-1];
  }
  counters[0] = firstCounter;
  int value = [ZXAbstractRSSReader parseFinderValue:counters countersSize:countersLen finderPatternType:RSS_PATTERNS_RSS14_PATTERNS];
  int start = firstElementStart;
  int end = [[startEnd objectAtIndex:1] intValue];
  if (right) {
    start = [row size] - 1 - start;
    end = [row size] - 1 - end;
  }
  return [[[ZXRSSFinderPattern alloc] initWithValue:value
                                         startEnd:[NSArray arrayWithObjects:[NSNumber numberWithInt:firstElementStart], [startEnd objectAtIndex:1], nil] 
                                            start:start
                                              end:end
                                        rowNumber:rowNumber] autorelease];
}

- (void) adjustOddEvenCounts:(BOOL)outsideChar numModules:(int)numModules {
  int oddSum = [ZXAbstractRSSReader countArray:oddCounts];
  int evenSum = [ZXAbstractRSSReader countArray:evenCounts];
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
    [ZXAbstractRSSReader increment:oddCounts errors:oddRoundingErrors];
  }
  if (decrementOdd) {
    [ZXAbstractRSSReader decrement:oddCounts errors:oddRoundingErrors];
  }
  if (incrementEven) {
    if (decrementEven) {
      @throw [ZXNotFoundException notFoundInstance];
    }
    [ZXAbstractRSSReader increment:evenCounts errors:oddRoundingErrors];
  }
  if (decrementEven) {
    [ZXAbstractRSSReader decrement:evenCounts errors:evenRoundingErrors];
  }
}

- (void) dealloc {
  [possibleLeftPairs release];
  [possibleRightPairs release];
  [super dealloc];
}

@end
