#import "AbstractRSSReader.h"

int const MAX_AVG_VARIANCE = (int)(PATTERN_MATCH_RESULT_SCALE_FACTOR * 0.2f);
int const MAX_INDIVIDUAL_VARIANCE = (int)(PATTERN_MATCH_RESULT_SCALE_FACTOR * 0.4f);
float const MIN_FINDER_PATTERN_RATIO = 9.5f / 12.0f;
float const MAX_FINDER_PATTERN_RATIO = 12.5f / 14.0f;

@implementation AbstractRSSReader

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

+ (int) parseFinderValue:(int[])counters finderPatterns:(int*[])finderPatterns {
  for (int value = 0; value < sizeof((int*)finderPatterns) / sizeof(int); value++) {
    if ([self patternMatchVariance:counters pattern:finderPatterns[value] maxIndividualVariance:MAX_INDIVIDUAL_VARIANCE] < MAX_AVG_VARIANCE) {
      return value;
    }
  }

  @throw [NotFoundException notFoundInstance];
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
