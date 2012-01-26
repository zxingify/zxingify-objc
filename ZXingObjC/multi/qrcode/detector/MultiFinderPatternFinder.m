#import "MultiFinderPatternFinder.h"

@implementation ModuleSizeComparator

- (int) compare:(NSObject *)center1 center2:(NSObject *)center2 {
  float value = [((FinderPattern *)center2) estimatedModuleSize] - [((FinderPattern *)center1) estimatedModuleSize];
  return value < 0.0 ? -1 : value > 0.0 ? 1 : 0;
}

@end

NSArray * const EMPTY_RESULT_ARRAY = [NSArray array];
float const MAX_MODULE_COUNT_PER_EDGE = 180;
float const MIN_MODULE_COUNT_PER_EDGE = 9;

/**
 * More or less arbitrary cutoff point for determining if two finder patterns might belong
 * to the same code if they differ less than DIFF_MODSIZE_CUTOFF_PERCENT percent in their
 * estimated modules sizes.
 */
float const DIFF_MODSIZE_CUTOFF_PERCENT = 0.05f;

/**
 * More or less arbitrary cutoff point for determining if two finder patterns might belong
 * to the same code if they differ less than DIFF_MODSIZE_CUTOFF pixels/module in their
 * estimated modules sizes.
 */
float const DIFF_MODSIZE_CUTOFF = 0.5f;

@implementation MultiFinderPatternFinder


/**
 * <p>Creates a finder that will search the image for three finder patterns.</p>
 * 
 * @param image image to search
 */
- (id) initWithImage:(BitMatrix *)image {
  if (self = [super init:image]) {
  }
  return self;
}

- (id) init:(BitMatrix *)image resultPointCallback:(ResultPointCallback *)resultPointCallback {
  if (self = [super init:image param1:resultPointCallback]) {
  }
  return self;
}


/**
 * @return the 3 best {@link FinderPattern}s from our list of candidates. The "best" are
 * those that have been detected at least {@link #CENTER_QUORUM} times, and whose module
 * size differs from the average among those patterns the least
 * @throws NotFoundException if 3 such finder patterns do not exist
 */
- (NSArray *) selectBestPatterns {
  NSMutableArray * possibleCenters = [self possibleCenters];
  int size = [possibleCenters count];
  if (size < 3) {
    @throw [NotFoundException notFoundInstance];
  }
  if (size == 3) {
    return [NSArray arrayWithObjects:[NSArray arrayWithObjects:(FinderPattern *)[possibleCenters objectAtIndex:0], (FinderPattern *)[possibleCenters objectAtIndex:1], (FinderPattern *)[possibleCenters objectAtIndex:2], nil], nil];
  }
  [Collections insertionSort:possibleCenters param1:[[[ModuleSizeComparator alloc] init] autorelease]];
  NSMutableArray * results = [[[NSMutableArray alloc] init] autorelease];

  for (int i1 = 0; i1 < (size - 2); i1++) {
    FinderPattern * p1 = (FinderPattern *)[possibleCenters objectAtIndex:i1];
    if (p1 == nil) {
      continue;
    }

    for (int i2 = i1 + 1; i2 < (size - 1); i2++) {
      FinderPattern * p2 = (FinderPattern *)[possibleCenters objectAtIndex:i2];
      if (p2 == nil) {
        continue;
      }
      float vModSize12 = ([p1 estimatedModuleSize] - [p2 estimatedModuleSize]) / [Math min:[p1 estimatedModuleSize] param1:[p2 estimatedModuleSize]];
      float vModSize12A = [Math abs:[p1 estimatedModuleSize] - [p2 estimatedModuleSize]];
      if (vModSize12A > DIFF_MODSIZE_CUTOFF && vModSize12 >= DIFF_MODSIZE_CUTOFF_PERCENT) {
        break;
      }

      for (int i3 = i2 + 1; i3 < size; i3++) {
        FinderPattern * p3 = (FinderPattern *)[possibleCenters objectAtIndex:i3];
        if (p3 == nil) {
          continue;
        }
        float vModSize23 = ([p2 estimatedModuleSize] - [p3 estimatedModuleSize]) / [Math min:[p2 estimatedModuleSize] param1:[p3 estimatedModuleSize]];
        float vModSize23A = [Math abs:[p2 estimatedModuleSize] - [p3 estimatedModuleSize]];
        if (vModSize23A > DIFF_MODSIZE_CUTOFF && vModSize23 >= DIFF_MODSIZE_CUTOFF_PERCENT) {
          break;
        }
        NSArray * test = [NSArray arrayWithObjects:p1, p2, p3, nil];
        [ResultPoint orderBestPatterns:test];
        FinderPatternInfo * info = [[[FinderPatternInfo alloc] init:test] autorelease];
        float dA = [ResultPoint distance:[info topLeft] param1:[info bottomLeft]];
        float dC = [ResultPoint distance:[info topRight] param1:[info bottomLeft]];
        float dB = [ResultPoint distance:[info topLeft] param1:[info topRight]];
        float estimatedModuleCount = (dA + dB) / ([p1 estimatedModuleSize] * 2.0f);
        if (estimatedModuleCount > MAX_MODULE_COUNT_PER_EDGE || estimatedModuleCount < MIN_MODULE_COUNT_PER_EDGE) {
          continue;
        }
        float vABBC = [Math abs:(dA - dB) / [Math min:dA param1:dB]];
        if (vABBC >= 0.1f) {
          continue;
        }
        float dCpy = (float)[Math sqrt:dA * dA + dB * dB];
        float vPyC = [Math abs:(dC - dCpy) / [Math min:dC param1:dCpy]];
        if (vPyC >= 0.1f) {
          continue;
        }
        [results addObject:test];
      }

    }

  }

  if (![results empty]) {
    NSArray * resultArray = [NSArray array];

    for (int i = 0; i < [results count]; i++) {
      resultArray[i] = (NSArray *)[results objectAtIndex:i];
    }

    return resultArray;
  }
  @throw [NotFoundException notFoundInstance];
}

- (NSArray *) findMulti:(NSMutableDictionary *)hints {
  BOOL tryHarder = hints != nil && [hints containsKey:DecodeHintType.TRY_HARDER];
  BitMatrix * image = [self image];
  int maxI = [image height];
  int maxJ = [image width];
  int iSkip = (int)(maxI / (MAX_MODULES * 4.0f) * 3);
  if (iSkip < MIN_SKIP || tryHarder) {
    iSkip = MIN_SKIP;
  }
  NSArray * stateCount = [NSArray array];

  for (int i = iSkip - 1; i < maxI; i += iSkip) {
    stateCount[0] = 0;
    stateCount[1] = 0;
    stateCount[2] = 0;
    stateCount[3] = 0;
    stateCount[4] = 0;
    int currentState = 0;

    for (int j = 0; j < maxJ; j++) {
      if ([image get:j param1:i]) {
        if ((currentState & 1) == 1) {
          currentState++;
        }
        stateCount[currentState]++;
      }
       else {
        if ((currentState & 1) == 0) {
          if (currentState == 4) {
            if ([self foundPatternCross:stateCount]) {
              BOOL confirmed = [self handlePossibleCenter:stateCount param1:i param2:j];
              if (!confirmed) {

                do {
                  j++;
                }
                 while (j < maxJ && ![image get:j param1:i]);
                j--;
              }
              currentState = 0;
              stateCount[0] = 0;
              stateCount[1] = 0;
              stateCount[2] = 0;
              stateCount[3] = 0;
              stateCount[4] = 0;
            }
             else {
              stateCount[0] = stateCount[2];
              stateCount[1] = stateCount[3];
              stateCount[2] = stateCount[4];
              stateCount[3] = 1;
              stateCount[4] = 0;
              currentState = 3;
            }
          }
           else {
            stateCount[++currentState]++;
          }
        }
         else {
          stateCount[currentState]++;
        }
      }
    }

    if ([self foundPatternCross:stateCount]) {
      [self handlePossibleCenter:stateCount param1:i param2:maxJ];
    }
  }

  NSArray * patternInfo = [self selectBestPatterns];
  NSMutableArray * result = [[[NSMutableArray alloc] init] autorelease];

  for (int i = 0; i < patternInfo.length; i++) {
    NSArray * pattern = patternInfo[i];
    [ResultPoint orderBestPatterns:pattern];
    [result addObject:[[[FinderPatternInfo alloc] init:pattern] autorelease]];
  }

  if ([result empty]) {
    return EMPTY_RESULT_ARRAY;
  }
   else {
    NSArray * resultArray = [NSArray array];

    for (int i = 0; i < [result count]; i++) {
      resultArray[i] = (FinderPatternInfo *)[result objectAtIndex:i];
    }

    return resultArray;
  }
}

@end
