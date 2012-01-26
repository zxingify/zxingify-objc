#import "AlignmentPatternFinder.h"

@implementation AlignmentPatternFinder


/**
 * <p>Creates a finder that will look in a portion of the whole image.</p>
 * 
 * @param image image to search
 * @param startX left column from which to start searching
 * @param startY top row from which to start searching
 * @param width width of region to search
 * @param height height of region to search
 * @param moduleSize estimated module size so far
 */
- (id) init:(BitMatrix *)image startX:(int)startX startY:(int)startY width:(int)width height:(int)height moduleSize:(float)moduleSize resultPointCallback:(ResultPointCallback *)resultPointCallback {
  if (self = [super init]) {
    image = image;
    possibleCenters = [[[NSMutableArray alloc] init:5] autorelease];
    startX = startX;
    startY = startY;
    width = width;
    height = height;
    moduleSize = moduleSize;
    crossCheckStateCount = [NSArray array];
    resultPointCallback = resultPointCallback;
  }
  return self;
}


/**
 * <p>This method attempts to find the bottom-right alignment pattern in the image. It is a bit messy since
 * it's pretty performance-critical and so is written to be fast foremost.</p>
 * 
 * @return {@link AlignmentPattern} if found
 * @throws NotFoundException if not found
 */
- (AlignmentPattern *) find {
  int startX = startX;
  int height = height;
  int maxJ = startX + width;
  int middleI = startY + (height >> 1);
  NSArray * stateCount = [NSArray array];

  for (int iGen = 0; iGen < height; iGen++) {
    int i = middleI + ((iGen & 0x01) == 0 ? (iGen + 1) >> 1 : -((iGen + 1) >> 1));
    stateCount[0] = 0;
    stateCount[1] = 0;
    stateCount[2] = 0;
    int j = startX;

    while (j < maxJ && ![image get:j param1:i]) {
      j++;
    }

    int currentState = 0;

    while (j < maxJ) {
      if ([image get:j param1:i]) {
        if (currentState == 1) {
          stateCount[currentState]++;
        }
         else {
          if (currentState == 2) {
            if ([self foundPatternCross:stateCount]) {
              AlignmentPattern * confirmed = [self handlePossibleCenter:stateCount i:i j:j];
              if (confirmed != nil) {
                return confirmed;
              }
            }
            stateCount[0] = stateCount[2];
            stateCount[1] = 1;
            stateCount[2] = 0;
            currentState = 1;
          }
           else {
            stateCount[++currentState]++;
          }
        }
      }
       else {
        if (currentState == 1) {
          currentState++;
        }
        stateCount[currentState]++;
      }
      j++;
    }

    if ([self foundPatternCross:stateCount]) {
      AlignmentPattern * confirmed = [self handlePossibleCenter:stateCount i:i j:maxJ];
      if (confirmed != nil) {
        return confirmed;
      }
    }
  }

  if (![possibleCenters empty]) {
    return (AlignmentPattern *)[possibleCenters objectAtIndex:0];
  }
  @throw [NotFoundException notFoundInstance];
}


/**
 * Given a count of black/white/black pixels just seen and an end position,
 * figures the location of the center of this black/white/black run.
 */
+ (float) centerFromEnd:(NSArray *)stateCount end:(int)end {
  return (float)(end - stateCount[2]) - stateCount[1] / 2.0f;
}


/**
 * @param stateCount count of black/white/black pixels just read
 * @return true iff the proportions of the counts is close enough to the 1/1/1 ratios
 * used by alignment patterns to be considered a match
 */
- (BOOL) foundPatternCross:(NSArray *)stateCount {
  float moduleSize = moduleSize;
  float maxVariance = moduleSize / 2.0f;

  for (int i = 0; i < 3; i++) {
    if ([Math abs:moduleSize - stateCount[i]] >= maxVariance) {
      return NO;
    }
  }

  return YES;
}


/**
 * <p>After a horizontal scan finds a potential alignment pattern, this method
 * "cross-checks" by scanning down vertically through the center of the possible
 * alignment pattern to see if the same proportion is detected.</p>
 * 
 * @param startI row where an alignment pattern was detected
 * @param centerJ center of the section that appears to cross an alignment pattern
 * @param maxCount maximum reasonable number of modules that should be
 * observed in any reading state, based on the results of the horizontal scan
 * @return vertical center of alignment pattern, or {@link Float#NaN} if not found
 */
- (float) crossCheckVertical:(int)startI centerJ:(int)centerJ maxCount:(int)maxCount originalStateCountTotal:(int)originalStateCountTotal {
  BitMatrix * image = image;
  int maxI = [image height];
  NSArray * stateCount = crossCheckStateCount;
  stateCount[0] = 0;
  stateCount[1] = 0;
  stateCount[2] = 0;
  int i = startI;

  while (i >= 0 && [image get:centerJ param1:i] && stateCount[1] <= maxCount) {
    stateCount[1]++;
    i--;
  }

  if (i < 0 || stateCount[1] > maxCount) {
    return Float.NaN;
  }

  while (i >= 0 && ![image get:centerJ param1:i] && stateCount[0] <= maxCount) {
    stateCount[0]++;
    i--;
  }

  if (stateCount[0] > maxCount) {
    return Float.NaN;
  }
  i = startI + 1;

  while (i < maxI && [image get:centerJ param1:i] && stateCount[1] <= maxCount) {
    stateCount[1]++;
    i++;
  }

  if (i == maxI || stateCount[1] > maxCount) {
    return Float.NaN;
  }

  while (i < maxI && ![image get:centerJ param1:i] && stateCount[2] <= maxCount) {
    stateCount[2]++;
    i++;
  }

  if (stateCount[2] > maxCount) {
    return Float.NaN;
  }
  int stateCountTotal = stateCount[0] + stateCount[1] + stateCount[2];
  if (5 * [Math abs:stateCountTotal - originalStateCountTotal] >= 2 * originalStateCountTotal) {
    return Float.NaN;
  }
  return [self foundPatternCross:stateCount] ? [self centerFromEnd:stateCount end:i] : Float.NaN;
}


/**
 * <p>This is called when a horizontal scan finds a possible alignment pattern. It will
 * cross check with a vertical scan, and if successful, will see if this pattern had been
 * found on a previous horizontal scan. If so, we consider it confirmed and conclude we have
 * found the alignment pattern.</p>
 * 
 * @param stateCount reading state module counts from horizontal scan
 * @param i row where alignment pattern may be found
 * @param j end of possible alignment pattern in row
 * @return {@link AlignmentPattern} if we have found the same pattern twice, or null if not
 */
- (AlignmentPattern *) handlePossibleCenter:(NSArray *)stateCount i:(int)i j:(int)j {
  int stateCountTotal = stateCount[0] + stateCount[1] + stateCount[2];
  float centerJ = [self centerFromEnd:stateCount end:j];
  float centerI = [self crossCheckVertical:i centerJ:(int)centerJ maxCount:2 * stateCount[1] originalStateCountTotal:stateCountTotal];
  if (![Float isNaN:centerI]) {
    float estimatedModuleSize = (float)(stateCount[0] + stateCount[1] + stateCount[2]) / 3.0f;
    int max = [possibleCenters count];

    for (int index = 0; index < max; index++) {
      AlignmentPattern * center = (AlignmentPattern *)[possibleCenters objectAtIndex:index];
      if ([center aboutEquals:estimatedModuleSize param1:centerI param2:centerJ]) {
        return [[[AlignmentPattern alloc] init:centerJ param1:centerI param2:estimatedModuleSize] autorelease];
      }
    }

    ResultPoint * point = [[[AlignmentPattern alloc] init:centerJ param1:centerI param2:estimatedModuleSize] autorelease];
    [possibleCenters addObject:point];
    if (resultPointCallback != nil) {
      [resultPointCallback foundPossibleResultPoint:point];
    }
  }
  return nil;
}

- (void) dealloc {
  [image release];
  [possibleCenters release];
  [crossCheckStateCount release];
  [resultPointCallback release];
  [super dealloc];
}

@end
