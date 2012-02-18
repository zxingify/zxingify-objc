#import "FinderPatternFinder.h"

@implementation FurthestFromAverageComparator

- (id) initWithF:(float)f {
  if (self = [super init]) {
    average = f;
  }
  return self;
}

- (int) compare:(NSObject *)center1 center2:(NSObject *)center2 {
  float dA = [Math abs:[((FinderPattern *)center2) estimatedModuleSize] - average];
  float dB = [Math abs:[((FinderPattern *)center1) estimatedModuleSize] - average];
  return dA < dB ? -1 : dA == dB ? 0 : 1;
}

@end

@implementation CenterComparator

- (id) initWithF:(float)f {
  if (self = [super init]) {
    average = f;
  }
  return self;
}

- (int) compare:(NSObject *)center1 center2:(NSObject *)center2 {
  if ([((FinderPattern *)center2) count] == [((FinderPattern *)center1) count]) {
    float dA = [Math abs:[((FinderPattern *)center2) estimatedModuleSize] - average];
    float dB = [Math abs:[((FinderPattern *)center1) estimatedModuleSize] - average];
    return dA < dB ? 1 : dA == dB ? 0 : -1;
  }
   else {
    return [((FinderPattern *)center2) count] - [((FinderPattern *)center1) count];
  }
}

@end

int const CENTER_QUORUM = 2;
int const MIN_SKIP = 3;
int const MAX_MODULES = 57;
int const INTEGER_MATH_SHIFT = 8;

@implementation FinderPatternFinder


/**
 * <p>Creates a finder that will search the image for three finder patterns.</p>
 * 
 * @param image image to search
 */
- (id) initWithImage:(BitMatrix *)image {
  if (self = [self init:image resultPointCallback:nil]) {
  }
  return self;
}

- (id) initWithImage:(BitMatrix *)image resultPointCallback:(ResultPointCallback *)resultPointCallback {
  if (self = [super init]) {
    image = image;
    possibleCenters = [[[NSMutableArray alloc] init] autorelease];
    crossCheckStateCount = [NSArray array];
    resultPointCallback = resultPointCallback;
  }
  return self;
}

- (BitMatrix *) getImage {
  return image;
}

- (NSMutableArray *) getPossibleCenters {
  return possibleCenters;
}

- (FinderPatternInfo *) find:(NSMutableDictionary *)hints {
  BOOL tryHarder = hints != nil && [hints containsKey:DecodeHintType.TRY_HARDER];
  int maxI = [image height];
  int maxJ = [image width];
  int iSkip = (3 * maxI) / (4 * MAX_MODULES);
  if (iSkip < MIN_SKIP || tryHarder) {
    iSkip = MIN_SKIP;
  }
  BOOL done = NO;
  NSArray * stateCount = [NSArray array];

  for (int i = iSkip - 1; i < maxI && !done; i += iSkip) {
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
              BOOL confirmed = [self handlePossibleCenter:stateCount i:i j:j];
              if (confirmed) {
                iSkip = 2;
                if (hasSkipped) {
                  done = [self haveMultiplyConfirmedCenters];
                }
                 else {
                  int rowSkip = [self findRowSkip];
                  if (rowSkip > stateCount[2]) {
                    i += rowSkip - stateCount[2] - iSkip;
                    j = maxJ - 1;
                  }
                }
              }
               else {
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
      BOOL confirmed = [self handlePossibleCenter:stateCount i:i j:maxJ];
      if (confirmed) {
        iSkip = stateCount[0];
        if (hasSkipped) {
          done = [self haveMultiplyConfirmedCenters];
        }
      }
    }
  }

  NSArray * patternInfo = [self selectBestPatterns];
  [ResultPoint orderBestPatterns:patternInfo];
  return [[[FinderPatternInfo alloc] init:patternInfo] autorelease];
}


/**
 * Given a count of black/white/black/white/black pixels just seen and an end position,
 * figures the location of the center of this run.
 */
+ (float) centerFromEnd:(NSArray *)stateCount end:(int)end {
  return (float)(end - stateCount[4] - stateCount[3]) - stateCount[2] / 2.0f;
}


/**
 * @param stateCount count of black/white/black/white/black pixels just read
 * @return true iff the proportions of the counts is close enough to the 1/1/3/1/1 ratios
 * used by finder patterns to be considered a match
 */
+ (BOOL) foundPatternCross:(NSArray *)stateCount {
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
  return [Math abs:moduleSize - (stateCount[0] << INTEGER_MATH_SHIFT)] < maxVariance && [Math abs:moduleSize - (stateCount[1] << INTEGER_MATH_SHIFT)] < maxVariance && [Math abs:3 * moduleSize - (stateCount[2] << INTEGER_MATH_SHIFT)] < 3 * maxVariance && [Math abs:moduleSize - (stateCount[3] << INTEGER_MATH_SHIFT)] < maxVariance && [Math abs:moduleSize - (stateCount[4] << INTEGER_MATH_SHIFT)] < maxVariance;
}

- (NSArray *) getCrossCheckStateCount {
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
  BitMatrix * image = image;
  int maxI = [image height];
  NSArray * stateCount = [self crossCheckStateCount];
  int i = startI;

  while (i >= 0 && [image get:centerJ param1:i]) {
    stateCount[2]++;
    i--;
  }

  if (i < 0) {
    return Float.NaN;
  }

  while (i >= 0 && ![image get:centerJ param1:i] && stateCount[1] <= maxCount) {
    stateCount[1]++;
    i--;
  }

  if (i < 0 || stateCount[1] > maxCount) {
    return Float.NaN;
  }

  while (i >= 0 && [image get:centerJ param1:i] && stateCount[0] <= maxCount) {
    stateCount[0]++;
    i--;
  }

  if (stateCount[0] > maxCount) {
    return Float.NaN;
  }
  i = startI + 1;

  while (i < maxI && [image get:centerJ param1:i]) {
    stateCount[2]++;
    i++;
  }

  if (i == maxI) {
    return Float.NaN;
  }

  while (i < maxI && ![image get:centerJ param1:i] && stateCount[3] < maxCount) {
    stateCount[3]++;
    i++;
  }

  if (i == maxI || stateCount[3] >= maxCount) {
    return Float.NaN;
  }

  while (i < maxI && [image get:centerJ param1:i] && stateCount[4] < maxCount) {
    stateCount[4]++;
    i++;
  }

  if (stateCount[4] >= maxCount) {
    return Float.NaN;
  }
  int stateCountTotal = stateCount[0] + stateCount[1] + stateCount[2] + stateCount[3] + stateCount[4];
  if (5 * [Math abs:stateCountTotal - originalStateCountTotal] >= 2 * originalStateCountTotal) {
    return Float.NaN;
  }
  return [self foundPatternCross:stateCount] ? [self centerFromEnd:stateCount end:i] : Float.NaN;
}


/**
 * <p>Like {@link #crossCheckVertical(int, int, int, int)}, and in fact is basically identical,
 * except it reads horizontally instead of vertically. This is used to cross-cross
 * check a vertical cross check and locate the real center of the alignment pattern.</p>
 */
- (float) crossCheckHorizontal:(int)startJ centerI:(int)centerI maxCount:(int)maxCount originalStateCountTotal:(int)originalStateCountTotal {
  BitMatrix * image = image;
  int maxJ = [image width];
  NSArray * stateCount = [self crossCheckStateCount];
  int j = startJ;

  while (j >= 0 && [image get:j param1:centerI]) {
    stateCount[2]++;
    j--;
  }

  if (j < 0) {
    return Float.NaN;
  }

  while (j >= 0 && ![image get:j param1:centerI] && stateCount[1] <= maxCount) {
    stateCount[1]++;
    j--;
  }

  if (j < 0 || stateCount[1] > maxCount) {
    return Float.NaN;
  }

  while (j >= 0 && [image get:j param1:centerI] && stateCount[0] <= maxCount) {
    stateCount[0]++;
    j--;
  }

  if (stateCount[0] > maxCount) {
    return Float.NaN;
  }
  j = startJ + 1;

  while (j < maxJ && [image get:j param1:centerI]) {
    stateCount[2]++;
    j++;
  }

  if (j == maxJ) {
    return Float.NaN;
  }

  while (j < maxJ && ![image get:j param1:centerI] && stateCount[3] < maxCount) {
    stateCount[3]++;
    j++;
  }

  if (j == maxJ || stateCount[3] >= maxCount) {
    return Float.NaN;
  }

  while (j < maxJ && [image get:j param1:centerI] && stateCount[4] < maxCount) {
    stateCount[4]++;
    j++;
  }

  if (stateCount[4] >= maxCount) {
    return Float.NaN;
  }
  int stateCountTotal = stateCount[0] + stateCount[1] + stateCount[2] + stateCount[3] + stateCount[4];
  if (5 * [Math abs:stateCountTotal - originalStateCountTotal] >= originalStateCountTotal) {
    return Float.NaN;
  }
  return [self foundPatternCross:stateCount] ? [self centerFromEnd:stateCount end:j] : Float.NaN;
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
- (BOOL) handlePossibleCenter:(NSArray *)stateCount i:(int)i j:(int)j {
  int stateCountTotal = stateCount[0] + stateCount[1] + stateCount[2] + stateCount[3] + stateCount[4];
  float centerJ = [self centerFromEnd:stateCount end:j];
  float centerI = [self crossCheckVertical:i centerJ:(int)centerJ maxCount:stateCount[2] originalStateCountTotal:stateCountTotal];
  if (![Float isNaN:centerI]) {
    centerJ = [self crossCheckHorizontal:(int)centerJ centerI:(int)centerI maxCount:stateCount[2] originalStateCountTotal:stateCountTotal];
    if (![Float isNaN:centerJ]) {
      float estimatedModuleSize = (float)stateCountTotal / 7.0f;
      BOOL found = NO;
      int max = [possibleCenters count];

      for (int index = 0; index < max; index++) {
        FinderPattern * center = (FinderPattern *)[possibleCenters objectAtIndex:index];
        if ([center aboutEquals:estimatedModuleSize param1:centerI param2:centerJ]) {
          [center incrementCount];
          found = YES;
          break;
        }
      }

      if (!found) {
        ResultPoint * point = [[[FinderPattern alloc] init:centerJ param1:centerI param2:estimatedModuleSize] autorelease];
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
  FinderPattern * firstConfirmedCenter = nil;

  for (int i = 0; i < max; i++) {
    FinderPattern * center = (FinderPattern *)[possibleCenters objectAtIndex:i];
    if ([center count] >= CENTER_QUORUM) {
      if (firstConfirmedCenter == nil) {
        firstConfirmedCenter = center;
      }
       else {
        hasSkipped = YES;
        return (int)([Math abs:[firstConfirmedCenter x] - [center x]] - [Math abs:[firstConfirmedCenter y] - [center y]]) / 2;
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
    FinderPattern * pattern = (FinderPattern *)[possibleCenters objectAtIndex:i];
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
    FinderPattern * pattern = (FinderPattern *)[possibleCenters objectAtIndex:i];
    totalDeviation += [Math abs:[pattern estimatedModuleSize] - average];
  }

  return totalDeviation <= 0.05f * totalModuleSize;
}


/**
 * @return the 3 best {@link FinderPattern}s from our list of candidates. The "best" are
 * those that have been detected at least {@link #CENTER_QUORUM} times, and whose module
 * size differs from the average among those patterns the least
 * @throws NotFoundException if 3 such finder patterns do not exist
 */
- (NSArray *) selectBestPatterns {
  int startSize = [possibleCenters count];
  if (startSize < 3) {
    @throw [NotFoundException notFoundInstance];
  }
  if (startSize > 3) {
    float totalModuleSize = 0.0f;
    float square = 0.0f;

    for (int i = 0; i < startSize; i++) {
      float size = [((FinderPattern *)[possibleCenters objectAtIndex:i]) estimatedModuleSize];
      totalModuleSize += size;
      square += size * size;
    }

    float average = totalModuleSize / (float)startSize;
    float stdDev = (float)[Math sqrt:square / startSize - average * average];
    [Collections insertionSort:possibleCenters param1:[[[FurthestFromAverageComparator alloc] init:average] autorelease]];
    float limit = [Math max:0.2f * average param1:stdDev];

    for (int i = 0; i < [possibleCenters count] && [possibleCenters count] > 3; i++) {
      FinderPattern * pattern = (FinderPattern *)[possibleCenters objectAtIndex:i];
      if ([Math abs:[pattern estimatedModuleSize] - average] > limit) {
        [possibleCenters removeObjectAtIndex:i];
        i--;
      }
    }

  }
  if ([possibleCenters count] > 3) {
    float totalModuleSize = 0.0f;

    for (int i = 0; i < [possibleCenters count]; i++) {
      totalModuleSize += [((FinderPattern *)[possibleCenters objectAtIndex:i]) estimatedModuleSize];
    }

    float average = totalModuleSize / (float)[possibleCenters count];
    [Collections insertionSort:possibleCenters param1:[[[CenterComparator alloc] init:average] autorelease]];
    [possibleCenters setSize:3];
  }
  return [NSArray arrayWithObjects:(FinderPattern *)[possibleCenters objectAtIndex:0], (FinderPattern *)[possibleCenters objectAtIndex:1], (FinderPattern *)[possibleCenters objectAtIndex:2], nil];
}

- (void) dealloc {
  [image release];
  [possibleCenters release];
  [crossCheckStateCount release];
  [resultPointCallback release];
  [super dealloc];
}

@end
