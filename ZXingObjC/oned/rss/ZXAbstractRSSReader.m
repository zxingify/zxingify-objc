#import "ZXAbstractRSSReader.h"

#define MAX_AVG_VARIANCE (int)(PATTERN_MATCH_RESULT_SCALE_FACTOR * 0.2f)
#define MAX_INDIVIDUAL_VARIANCE (int)(PATTERN_MATCH_RESULT_SCALE_FACTOR * 0.4f)

float const MIN_FINDER_PATTERN_RATIO = 9.5f / 12.0f;
float const MAX_FINDER_PATTERN_RATIO = 12.5f / 14.0f;

const int RSS14_FINDER_PATTERNS_LEN = 9;
const int RSS14_FINDER_PATTERNS_SUB_LEN = 4;
const int RSS14_FINDER_PATTERNS[RSS14_FINDER_PATTERNS_LEN][RSS14_FINDER_PATTERNS_SUB_LEN] = {
  {3,8,2,1},
  {3,5,5,1},
  {3,3,7,1},
  {3,1,9,1},
  {2,7,4,1},
  {2,5,6,1},
  {2,3,8,1},
  {1,5,7,1},
  {1,3,9,1},
};

const int RSS_EXPANDED_FINDER_PATTERNS_LEN = 6;
const int RSS_EXPANDED_FINDER_PATTERNS_SUB_LEN = 4;
const int RSS_EXPANDED_FINDER_PATTERNS[RSS_EXPANDED_FINDER_PATTERNS_LEN][RSS_EXPANDED_FINDER_PATTERNS_SUB_LEN] = {
  {1,8,4,1}, // A
  {3,6,4,1}, // B
  {3,4,6,1}, // C
  {3,2,8,1}, // D
  {2,6,5,1}, // E
  {2,2,9,1}  // F
};


@implementation ZXAbstractRSSReader

- (id) init {
  if (self = [super init]) {
    decodeFinderCounters = [NSArray array];
    dataCharacterCounters = [NSArray array];
    oddRoundingErrors = [NSArray array];
    evenRoundingErrors = [NSArray array];
    oddCounts = [NSMutableArray array];
    evenCounts = [NSMutableArray array];
  }
  return self;
}

+ (int) parseFinderValue:(int[])counters countersSize:(int)countersSize finderPatternType:(RSS_PATTERNS)finderPatternType {
  switch (finderPatternType) {
    case RSS_PATTERNS_RSS14_PATTERNS:
      for (int value = 0; value < RSS14_FINDER_PATTERNS_LEN; value++) {
        if ([self patternMatchVariance:counters countersSize:countersSize pattern:(int*)RSS14_FINDER_PATTERNS[value] maxIndividualVariance:MAX_INDIVIDUAL_VARIANCE] < MAX_AVG_VARIANCE) {
          return value;
        }
      }
      break;

    case RSS_PATTERNS_RSS_EXPANDED_PATTERNS:
      for (int value = 0; value < RSS_EXPANDED_FINDER_PATTERNS_LEN; value++) {
        if ([self patternMatchVariance:counters countersSize:countersSize pattern:(int*)RSS_EXPANDED_FINDER_PATTERNS[value] maxIndividualVariance:MAX_INDIVIDUAL_VARIANCE] < MAX_AVG_VARIANCE) {
          return value;
        }
      }
      break;
      
    default:
      break;
  }

  @throw [ZXNotFoundException notFoundInstance];
}

+ (int) count:(int[])array {
  int count = 0;

  for (int i = 0; i < sizeof((int*)array) / sizeof(int); i++) {
    count += array[i];
  }

  return count;
}

+ (int) countArray:(NSArray*)array {
  int count = 0;
  
  for (NSNumber *i in array) {
    count += [i intValue];
  }
  
  return count;
}

+ (void) increment:(NSMutableArray *)array errors:(NSArray *)errors {
  int index = 0;
  float biggestError = [[errors objectAtIndex:0] intValue];

  for (int i = 1; i < [array count]; i++) {
    if ([[errors objectAtIndex:i] intValue] > biggestError) {
      biggestError = [[errors objectAtIndex:i] intValue];
      index = i;
    }
  }

  [array replaceObjectAtIndex:index withObject:[NSNumber numberWithInt:[[array objectAtIndex:index] intValue] + 1]];
}

+ (void) decrement:(NSMutableArray *)array errors:(NSArray *)errors {
  int index = 0;
  float biggestError = [[errors objectAtIndex:0] intValue];

  for (int i = 1; i < [array count]; i++) {
    if ([[errors objectAtIndex:i] intValue] < biggestError) {
      biggestError = [[errors objectAtIndex:i] intValue];
      index = i;
    }
  }

  [array replaceObjectAtIndex:index withObject:[NSNumber numberWithInt:[[array objectAtIndex:index] intValue] - 1]];
}

+ (BOOL) isFinderPattern:(int[])counters {
  int firstTwoSum = counters[0] + counters[1];
  int sum = firstTwoSum + counters[2] + counters[3];
  float ratio = (float)firstTwoSum / (float)sum;
  if (ratio >= MIN_FINDER_PATTERN_RATIO && ratio <= MAX_FINDER_PATTERN_RATIO) {
    int minCounter = NSIntegerMax;
    int maxCounter = NSIntegerMin;
    for (int i = 0; i < sizeof((int*)counters) / sizeof(int); i++) {
      int counter = counters[i];
      if (counter > maxCounter) {
        maxCounter = counter;
      }
      if (counter < minCounter) {
        minCounter = counter;
      }
    }

    return maxCounter < 10 * minCounter;
  }
  return NO;
}

- (void) dealloc {
  [decodeFinderCounters release];
  [dataCharacterCounters release];
  [oddRoundingErrors release];
  [evenRoundingErrors release];
  [oddCounts release];
  [evenCounts release];
  [super dealloc];
}

@end
