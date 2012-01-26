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
    oddCounts = [NSArray array];
    evenCounts = [NSArray array];
  }
  return self;
}

+ (int) parseFinderValue:(NSArray *)counters finderPatterns:(NSArray *)finderPatterns {

  for (int value = 0; value < finderPatterns.length; value++) {
    if ([self patternMatchVariance:counters param1:finderPatterns[value] param2:MAX_INDIVIDUAL_VARIANCE] < MAX_AVG_VARIANCE) {
      return value;
    }
  }

  @throw [NotFoundException notFoundInstance];
}

+ (int) count:(NSArray *)array {
  int count = 0;

  for (int i = 0; i < array.length; i++) {
    count += array[i];
  }

  return count;
}

+ (void) increment:(NSArray *)array errors:(NSArray *)errors {
  int index = 0;
  float biggestError = errors[0];

  for (int i = 1; i < array.length; i++) {
    if (errors[i] > biggestError) {
      biggestError = errors[i];
      index = i;
    }
  }

  array[index]++;
}

+ (void) decrement:(NSArray *)array errors:(NSArray *)errors {
  int index = 0;
  float biggestError = errors[0];

  for (int i = 1; i < array.length; i++) {
    if (errors[i] < biggestError) {
      biggestError = errors[i];
      index = i;
    }
  }

  array[index]--;
}

+ (BOOL) isFinderPattern:(NSArray *)counters {
  int firstTwoSum = counters[0] + counters[1];
  int sum = firstTwoSum + counters[2] + counters[3];
  float ratio = (float)firstTwoSum / (float)sum;
  if (ratio >= MIN_FINDER_PATTERN_RATIO && ratio <= MAX_FINDER_PATTERN_RATIO) {
    int minCounter = Integer.MAX_VALUE;
    int maxCounter = Integer.MIN_VALUE;

    for (int i = 0; i < counters.length; i++) {
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
