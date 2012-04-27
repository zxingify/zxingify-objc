#import "ZXBitMatrix.h"
#import "ZXDecodeHintType.h"
#import "ZXFinderPatternFinder.h"
#import "ZXFinderPatternInfo.h"
#import "ZXNotFoundException.h"
#import "ZXOneDReader.h"
#import "ZXQRCodeFinderPattern.h"
#import "ZXResultPoint.h"
#import "ZXResultPointCallback.h"

int const CENTER_QUORUM = 2;
int const FINDER_PATTERN_MIN_SKIP = 3;
int const FINDER_PATTERN_MAX_MODULES = 57;

@interface ZXFinderPatternFinder ()

NSInteger centerCompare(id center1, id center2, void *context);
NSInteger furthestFromAverageCompare(id center1, id center2, void *context);

- (float) centerFromEnd:(int[])stateCount end:(int)end;
- (int*) crossCheckStateCount;
- (int) findRowSkip;
- (BOOL) haveMultiplyConfirmedCenters;
- (NSMutableArray *) selectBestPatterns;

@end

@implementation ZXFinderPatternFinder

@synthesize image, possibleCenters;

/**
 * <p>Creates a finder that will search the image for three finder patterns.</p>
 * 
 * @param image image to search
 */
- (id) initWithImage:(ZXBitMatrix *)anImage {
  self = [self initWithImage:anImage resultPointCallback:nil];
  return self;
}

- (id) initWithImage:(ZXBitMatrix *)anImage resultPointCallback:(id <ZXResultPointCallback>)aResultPointCallback {
  if (self = [super init]) {
    image = [anImage retain];
    possibleCenters = [[NSMutableArray alloc] init];
    resultPointCallback = aResultPointCallback;
  }
  return self;
}

- (ZXFinderPatternInfo *) find:(NSMutableDictionary *)hints {
  BOOL tryHarder = hints != nil && [hints objectForKey:[NSNumber numberWithInt:kDecodeHintTypeTryHarder]];
  int maxI = [image height];
  int maxJ = [image width];
  int iSkip = (3 * maxI) / (4 * FINDER_PATTERN_MAX_MODULES);
  if (iSkip < FINDER_PATTERN_MIN_SKIP || tryHarder) {
    iSkip = FINDER_PATTERN_MIN_SKIP;
  }

  BOOL done = NO;
  int stateCount[5];
  for (int i = iSkip - 1; i < maxI && !done; i += iSkip) {
    stateCount[0] = 0;
    stateCount[1] = 0;
    stateCount[2] = 0;
    stateCount[3] = 0;
    stateCount[4] = 0;
    int currentState = 0;

    for (int j = 0; j < maxJ; j++) {
      if ([image get:j y:i]) {
        if ((currentState & 1) == 1) {
          currentState++;
        }
        stateCount[currentState]++;
      } else {
        if ((currentState & 1) == 0) {
          if (currentState == 4) {
            if ([ZXFinderPatternFinder foundPatternCross:stateCount]) {
              BOOL confirmed = [self handlePossibleCenter:stateCount i:i j:j];
              if (confirmed) {
                iSkip = 2;
                if (hasSkipped) {
                  done = [self haveMultiplyConfirmedCenters];
                } else {
                  int rowSkip = [self findRowSkip];
                  if (rowSkip > stateCount[2]) {
                    i += rowSkip - stateCount[2] - iSkip;
                    j = maxJ - 1;
                  }
                }
              } else {
                stateCount[0] = stateCount[2];
                stateCount[1] = stateCount[3];
                stateCount[2] = stateCount[4];
                stateCount[3] = 1;
                stateCount[4] = 0;
                currentState = 3;
                continue;
              }
              currentState = 0;
              stateCount[0] = 0;
              stateCount[1] = 0;
              stateCount[2] = 0;
              stateCount[3] = 0;
              stateCount[4] = 0;
            } else {
              stateCount[0] = stateCount[2];
              stateCount[1] = stateCount[3];
              stateCount[2] = stateCount[4];
              stateCount[3] = 1;
              stateCount[4] = 0;
              currentState = 3;
            }
          } else {
            stateCount[++currentState]++;
          }
        } else {
          stateCount[currentState]++;
        }
      }
    }

    if ([ZXFinderPatternFinder foundPatternCross:stateCount]) {
      BOOL confirmed = [self handlePossibleCenter:stateCount i:i j:maxJ];
      if (confirmed) {
        iSkip = stateCount[0];
        if (hasSkipped) {
          done = [self haveMultiplyConfirmedCenters];
        }
      }
    }
  }

  NSMutableArray * patternInfo = [self selectBestPatterns];
  [ZXResultPoint orderBestPatterns:patternInfo];
  return [[[ZXFinderPatternInfo alloc] initWithPatternCenters:patternInfo] autorelease];
}


/**
 * Given a count of black/white/black/white/black pixels just seen and an end position,
 * figures the location of the center of this run.
 */
- (float) centerFromEnd:(int[])stateCount end:(int)end {
  return (float)(end - stateCount[4] - stateCount[3]) - stateCount[2] / 2.0f;
}


/**
 * @param stateCount count of black/white/black/white/black pixels just read
 * @return true iff the proportions of the counts is close enough to the 1/1/3/1/1 ratios
 * used by finder patterns to be considered a match
 */
+ (BOOL) foundPatternCross:(int[])stateCount {
  int totalModuleSize = 0;

  for (int i = 0; i < 5; i++) {
    int count = stateCount[i];
    if (count == 0) {
      return NO;
    }
    totalModuleSize += count;
  }

  if (totalModuleSize < 7) {
    return NO;
  }
  int moduleSize = (totalModuleSize << INTEGER_MATH_SHIFT) / 7;
  int maxVariance = moduleSize / 2;
  return abs(moduleSize - (stateCount[0] << INTEGER_MATH_SHIFT)) < maxVariance &&
    abs(moduleSize - (stateCount[1] << INTEGER_MATH_SHIFT)) < maxVariance &&
    abs(3 * moduleSize - (stateCount[2] << INTEGER_MATH_SHIFT)) < 3 * maxVariance &&
    abs(moduleSize - (stateCount[3] << INTEGER_MATH_SHIFT)) < maxVariance &&
    abs(moduleSize - (stateCount[4] << INTEGER_MATH_SHIFT)) < maxVariance;
}

- (int*) crossCheckStateCount {
  crossCheckStateCount[0] = 0;
  crossCheckStateCount[1] = 0;
  crossCheckStateCount[2] = 0;
  crossCheckStateCount[3] = 0;
  crossCheckStateCount[4] = 0;
  return crossCheckStateCount;
}


/**
 * <p>After a horizontal scan finds a potential finder pattern, this method
 * "cross-checks" by scanning down vertically through the center of the possible
 * finder pattern to see if the same proportion is detected.</p>
 * 
 * @param startI row where a finder pattern was detected
 * @param centerJ center of the section that appears to cross a finder pattern
 * @param maxCount maximum reasonable number of modules that should be
 * observed in any reading state, based on the results of the horizontal scan
 * @return vertical center of finder pattern, or {@link Float#NaN} if not found
 */
- (float) crossCheckVertical:(int)startI centerJ:(int)centerJ maxCount:(int)maxCount originalStateCountTotal:(int)originalStateCountTotal {
  int maxI = [image height];
  int* stateCount = [self crossCheckStateCount];

  int i = startI;
  while (i >= 0 && [image get:centerJ y:i]) {
    stateCount[2]++;
    i--;
  }
  if (i < 0) {
    return NAN;
  }
  while (i >= 0 && ![image get:centerJ y:i] && stateCount[1] <= maxCount) {
    stateCount[1]++;
    i--;
  }
  if (i < 0 || stateCount[1] > maxCount) {
    return NAN;
  }
  while (i >= 0 && [image get:centerJ y:i] && stateCount[0] <= maxCount) {
    stateCount[0]++;
    i--;
  }
  if (stateCount[0] > maxCount) {
    return NAN;
  }

  i = startI + 1;
  while (i < maxI && [image get:centerJ y:i]) {
    stateCount[2]++;
    i++;
  }
  if (i == maxI) {
    return NAN;
  }
  while (i < maxI && ![image get:centerJ y:i] && stateCount[3] < maxCount) {
    stateCount[3]++;
    i++;
  }
  if (i == maxI || stateCount[3] >= maxCount) {
    return NAN;
  }
  while (i < maxI && [image get:centerJ y:i] && stateCount[4] < maxCount) {
    stateCount[4]++;
    i++;
  }
  if (stateCount[4] >= maxCount) {
    return NAN;
  }

  int stateCountTotal = stateCount[0] + stateCount[1] + stateCount[2] + stateCount[3] + stateCount[4];
  if (5 * abs(stateCountTotal - originalStateCountTotal) >= 2 * originalStateCountTotal) {
    return NAN;
  }
  return [ZXFinderPatternFinder foundPatternCross:stateCount] ? [self centerFromEnd:stateCount end:i] : NAN;
}


/**
 * <p>Like {@link #crossCheckVertical(int, int, int, int)}, and in fact is basically identical,
 * except it reads horizontally instead of vertically. This is used to cross-cross
 * check a vertical cross check and locate the real center of the alignment pattern.</p>
 */
- (float) crossCheckHorizontal:(int)startJ centerI:(int)centerI maxCount:(int)maxCount originalStateCountTotal:(int)originalStateCountTotal {
  int maxJ = [image width];
  int* stateCount = [self crossCheckStateCount];

  int j = startJ;
  while (j >= 0 && [image get:j y:centerI]) {
    stateCount[2]++;
    j--;
  }
  if (j < 0) {
    return NAN;
  }
  while (j >= 0 && ![image get:j y:centerI] && stateCount[1] <= maxCount) {
    stateCount[1]++;
    j--;
  }
  if (j < 0 || stateCount[1] > maxCount) {
    return NAN;
  }
  while (j >= 0 && [image get:j y:centerI] && stateCount[0] <= maxCount) {
    stateCount[0]++;
    j--;
  }
  if (stateCount[0] > maxCount) {
    return NAN;
  }

  j = startJ + 1;
  while (j < maxJ && [image get:j y:centerI]) {
    stateCount[2]++;
    j++;
  }
  if (j == maxJ) {
    return NAN;
  }
  while (j < maxJ && ![image get:j y:centerI] && stateCount[3] < maxCount) {
    stateCount[3]++;
    j++;
  }
  if (j == maxJ || stateCount[3] >= maxCount) {
    return NAN;
  }
  while (j < maxJ && [image get:j y:centerI] && stateCount[4] < maxCount) {
    stateCount[4]++;
    j++;
  }
  if (stateCount[4] >= maxCount) {
    return NAN;
  }

  int stateCountTotal = stateCount[0] + stateCount[1] + stateCount[2] + stateCount[3] + stateCount[4];
  if (5 * abs(stateCountTotal - originalStateCountTotal) >= originalStateCountTotal) {
    return NAN;
  }

  return [ZXFinderPatternFinder foundPatternCross:stateCount] ? [self centerFromEnd:stateCount end:j] : NAN;
}


/**
 * <p>This is called when a horizontal scan finds a possible alignment pattern. It will
 * cross check with a vertical scan, and if successful, will, ah, cross-cross-check
 * with another horizontal scan. This is needed primarily to locate the real horizontal
 * center of the pattern in cases of extreme skew.</p>
 * 
 * <p>If that succeeds the finder pattern location is added to a list that tracks
 * the number of times each location has been nearly-matched as a finder pattern.
 * Each additional find is more evidence that the location is in fact a finder
 * pattern center
 * 
 * @param stateCount reading state module counts from horizontal scan
 * @param i row where finder pattern may be found
 * @param j end of possible finder pattern in row
 * @return true if a finder pattern candidate was found this time
 */
- (BOOL) handlePossibleCenter:(int[])stateCount i:(int)i j:(int)j {
  int stateCountTotal = stateCount[0] + stateCount[1] + stateCount[2] + stateCount[3] + stateCount[4];
  float centerJ = [self centerFromEnd:stateCount end:j];
  float centerI = [self crossCheckVertical:i centerJ:(int)centerJ maxCount:stateCount[2] originalStateCountTotal:stateCountTotal];
  if (!isnan(centerI)) {
    centerJ = [self crossCheckHorizontal:(int)centerJ centerI:(int)centerI maxCount:stateCount[2] originalStateCountTotal:stateCountTotal];
    if (!isnan(centerJ)) {
      float estimatedModuleSize = (float)stateCountTotal / 7.0f;
      BOOL found = NO;
      int max = [possibleCenters count];
      for (int index = 0; index < max; index++) {
        ZXQRCodeFinderPattern * center = [possibleCenters objectAtIndex:index];
        if ([center aboutEquals:estimatedModuleSize i:centerI j:centerJ]) {
          [center incrementCount];
          found = YES;
          break;
        }
      }

      if (!found) {
        ZXResultPoint * point = [[[ZXQRCodeFinderPattern alloc] initWithPosX:centerJ posY:centerI estimatedModuleSize:estimatedModuleSize] autorelease];
        [possibleCenters addObject:point];
        if (resultPointCallback != nil) {
          [resultPointCallback foundPossibleResultPoint:point];
        }
      }
      return YES;
    }
  }
  return NO;
}


/**
 * @return number of rows we could safely skip during scanning, based on the first
 * two finder patterns that have been located. In some cases their position will
 * allow us to infer that the third pattern must lie below a certain point farther
 * down in the image.
 */
- (int) findRowSkip {
  int max = [possibleCenters count];
  if (max <= 1) {
    return 0;
  }
  ZXQRCodeFinderPattern * firstConfirmedCenter = nil;
  for (int i = 0; i < max; i++) {
    ZXQRCodeFinderPattern * center = [possibleCenters objectAtIndex:i];
    if ([center count] >= CENTER_QUORUM) {
      if (firstConfirmedCenter == nil) {
        firstConfirmedCenter = center;
      } else {
        hasSkipped = YES;
        return (int)(abs([firstConfirmedCenter x] - [center x]) - abs([firstConfirmedCenter y] - [center y])) / 2;
      }
    }
  }
  return 0;
}


/**
 * @return true iff we have found at least 3 finder patterns that have been detected
 * at least {@link #CENTER_QUORUM} times each, and, the estimated module size of the
 * candidates is "pretty similar"
 */
- (BOOL) haveMultiplyConfirmedCenters {
  int confirmedCount = 0;
  float totalModuleSize = 0.0f;
  int max = [possibleCenters count];
  for (int i = 0; i < max; i++) {
    ZXQRCodeFinderPattern * pattern = [possibleCenters objectAtIndex:i];
    if ([pattern count] >= CENTER_QUORUM) {
      confirmedCount++;
      totalModuleSize += [pattern estimatedModuleSize];
    }
  }
  if (confirmedCount < 3) {
    return NO;
  }

  float average = totalModuleSize / (float)max;
  float totalDeviation = 0.0f;
  for (int i = 0; i < max; i++) {
    ZXQRCodeFinderPattern * pattern = [possibleCenters objectAtIndex:i];
    totalDeviation += abs([pattern estimatedModuleSize] - average);
  }
  return totalDeviation <= 0.05f * totalModuleSize;
}

/**
 * <p>Orders by {@link FinderPattern#getCount()}, descending.</p>
 */
NSInteger centerCompare(id center1, id center2, void *context) {
  float average = [(NSNumber *)context floatValue];

  if ([((ZXQRCodeFinderPattern *)center2) count] == [((ZXQRCodeFinderPattern *)center1) count]) {
    float dA = abs([((ZXQRCodeFinderPattern *)center2) estimatedModuleSize] - average);
    float dB = abs([((ZXQRCodeFinderPattern *)center1) estimatedModuleSize] - average);
    return dA < dB ? 1 : dA == dB ? 0 : -1;
  } else {
    return [((ZXQRCodeFinderPattern *)center2) count] - [((ZXQRCodeFinderPattern *)center1) count];
  }
}

/**
 * <p>Orders by furthest from average</p>
 */
NSInteger furthestFromAverageCompare(id center1, id center2, void *context) {
  float average = [(NSNumber *)context floatValue];

  float dA = abs([((ZXQRCodeFinderPattern *)center2) estimatedModuleSize] - average);
  float dB = abs([((ZXQRCodeFinderPattern *)center1) estimatedModuleSize] - average);
  return dA < dB ? -1 : dA == dB ? 0 : 1;
}


/**
 * @return the 3 best {@link FinderPattern}s from our list of candidates. The "best" are
 * those that have been detected at least {@link #CENTER_QUORUM} times, and whose module
 * size differs from the average among those patterns the least
 * @throws NotFoundException if 3 such finder patterns do not exist
 */
- (NSMutableArray *) selectBestPatterns {
  int startSize = [possibleCenters count];
  if (startSize < 3) {
    @throw [ZXNotFoundException notFoundInstance];
  }

  if (startSize > 3) {
    float totalModuleSize = 0.0f;
    float square = 0.0f;
    for (int i = 0; i < startSize; i++) {
      float size = [[possibleCenters objectAtIndex:i] estimatedModuleSize];
      totalModuleSize += size;
      square += size * size;
    }
    float average = totalModuleSize / (float)startSize;
    float stdDev = (float)sqrt(square / startSize - average * average);

    [possibleCenters sortUsingFunction:furthestFromAverageCompare context:[NSNumber numberWithFloat:average]];

    float limit = MAX(0.2f * average, stdDev);

    for (int i = 0; i < [possibleCenters count] && [possibleCenters count] > 3; i++) {
      ZXQRCodeFinderPattern * pattern = [possibleCenters objectAtIndex:i];
      if (abs([pattern estimatedModuleSize] - average) > limit) {
        [possibleCenters removeObjectAtIndex:i];
        i--;
      }
    }
  }

  if ([possibleCenters count] > 3) {
    float totalModuleSize = 0.0f;
    for (int i = 0; i < [possibleCenters count]; i++) {
      totalModuleSize += [[possibleCenters objectAtIndex:i] estimatedModuleSize];
    }

    float average = totalModuleSize / (float)[possibleCenters count];

    [possibleCenters sortUsingFunction:centerCompare context:[NSNumber numberWithFloat:average]];

    NSMutableArray* newPossibleCenters = [[NSMutableArray alloc] initWithArray:[possibleCenters subarrayWithRange:NSMakeRange(0, 3)]];
    [possibleCenters release];
    possibleCenters = newPossibleCenters;
  }

  return [NSMutableArray arrayWithObjects:[possibleCenters objectAtIndex:0], [possibleCenters objectAtIndex:1], [possibleCenters objectAtIndex:2], nil];
}

- (void) dealloc {
  [image release];
//  [possibleCenters release];
  [super dealloc];
}

@end
