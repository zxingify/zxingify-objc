#import "ZXAlignmentPattern.h"
#import "ZXAlignmentPatternFinder.h"
#import "ZXBitMatrix.h"
#import "ZXNotFoundException.h"
#import "ZXResultPointCallback.h"

@interface ZXAlignmentPatternFinder ()

- (float) centerFromEnd:(int *)stateCount end:(int)end;
- (BOOL) foundPatternCross:(int *)stateCount;
- (ZXAlignmentPattern *) handlePossibleCenter:(int *)stateCount i:(int)i j:(int)j;

@end

@implementation ZXAlignmentPatternFinder


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
- (id) initWithImage:(ZXBitMatrix *)anImage startX:(int)aStartX startY:(int)aStartY width:(int)aWidth height:(int)aHeight moduleSize:(float)aModuleSize resultPointCallback:(id <ZXResultPointCallback>)aResultPointCallback {
  if (self = [super init]) {
    image = [anImage retain];
    possibleCenters = [[NSMutableArray alloc] initWithCapacity:5];
    for (int i = 0; i < 5; i++) {
      [possibleCenters addObject:[NSNull null]];
    }
    startX = aStartX;
    startY = aStartY;
    width = aWidth;
    height = aHeight;
    moduleSize = aModuleSize;
    crossCheckStateCount = (int*)malloc(3 * sizeof(int));
    resultPointCallback = aResultPointCallback;
  }
  return self;
}


/**
 * <p>This method attempts to find the bottom-right alignment pattern in the image. It is a bit messy since
 * it's pretty performance-critical and so is written to be fast foremost.</p>
 * 
 * @return {@link ZXAlignmentPattern} if found
 * @throws NotFoundException if not found
 */
- (ZXAlignmentPattern *) find {
  int maxJ = startX + width;
  int middleI = startY + (height >> 1);
  int stateCount[3];

  for (int iGen = 0; iGen < height; iGen++) {
    int i = middleI + ((iGen & 0x01) == 0 ? (iGen + 1) >> 1 : -((iGen + 1) >> 1));
    stateCount[0] = 0;
    stateCount[1] = 0;
    stateCount[2] = 0;
    int j = startX;

    while (j < maxJ && ![image get:j y:i]) {
      j++;
    }

    int currentState = 0;

    while (j < maxJ) {
      if ([image get:j y:i]) {
        if (currentState == 1) {
          stateCount[currentState]++;
        }
         else {
          if (currentState == 2) {
            if ([self foundPatternCross:stateCount]) {
              ZXAlignmentPattern * confirmed = [self handlePossibleCenter:stateCount i:i j:j];
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
      ZXAlignmentPattern * confirmed = [self handlePossibleCenter:stateCount i:i j:maxJ];
      if (confirmed != nil) {
        return confirmed;
      }
    }
  }

  if ([possibleCenters count] > 0) {
    return [possibleCenters objectAtIndex:0];
  }
  @throw [ZXNotFoundException notFoundInstance];
}


/**
 * Given a count of black/white/black pixels just seen and an end position,
 * figures the location of the center of this black/white/black run.
 */
- (float) centerFromEnd:(int *)stateCount end:(int)end {
  return (float)(end - stateCount[2]) - stateCount[1] / 2.0f;
}


/**
 * @param stateCount count of black/white/black pixels just read
 * @return true iff the proportions of the counts is close enough to the 1/1/1 ratios
 * used by alignment patterns to be considered a match
 */
- (BOOL) foundPatternCross:(int *)stateCount {
  float maxVariance = moduleSize / 2.0f;

  for (int i = 0; i < 3; i++) {
    if (abs(moduleSize - stateCount[i]) >= maxVariance) {
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
  int maxI = [image height];
  int stateCount[3];
  stateCount[0] = 0;
  stateCount[1] = 0;
  stateCount[2] = 0;
  int i = startI;

  while (i >= 0 && [image get:centerJ y:i] && stateCount[1] <= maxCount) {
    stateCount[1]++;
    i--;
  }

  if (i < 0 || stateCount[1] > maxCount) {
    return NAN;
  }

  while (i >= 0 && ![image get:centerJ y:i] && stateCount[0] <= maxCount) {
    stateCount[0]++;
    i--;
  }

  if (stateCount[0] > maxCount) {
    return NAN;
  }
  i = startI + 1;

  while (i < maxI && [image get:centerJ y:i] && stateCount[1] <= maxCount) {
    stateCount[1]++;
    i++;
  }

  if (i == maxI || stateCount[1] > maxCount) {
    return NAN;
  }

  while (i < maxI && ![image get:centerJ y:i] && stateCount[2] <= maxCount) {
    stateCount[2]++;
    i++;
  }

  if (stateCount[2] > maxCount) {
    return NAN;
  }
  int stateCountTotal = stateCount[0] + stateCount[1] + stateCount[2];
  if (5 * abs(stateCountTotal - originalStateCountTotal) >= 2 * originalStateCountTotal) {
    return NAN;
  }
  return [self foundPatternCross:stateCount] ? [self centerFromEnd:stateCount end:i] : NAN;
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
 * @return {@link ZXAlignmentPattern} if we have found the same pattern twice, or null if not
 */
- (ZXAlignmentPattern *) handlePossibleCenter:(int *)stateCount i:(int)i j:(int)j {
  int stateCountTotal = stateCount[0] + stateCount[1] + stateCount[2];
  float centerJ = [self centerFromEnd:stateCount end:j];
  float centerI = [self crossCheckVertical:i centerJ:(int)centerJ maxCount:2 * stateCount[1] originalStateCountTotal:stateCountTotal];
  if (!isnan(centerI)) {
    float estimatedModuleSize = (float)(stateCount[0] + stateCount[1] + stateCount[2]) / 3.0f;
    int max = [possibleCenters count];

    for (int index = 0; index < max; index++) {
      ZXAlignmentPattern * center = (ZXAlignmentPattern *)[possibleCenters objectAtIndex:index];
      if ([center aboutEquals:estimatedModuleSize i:centerI j:centerJ]) {
        return [[[ZXAlignmentPattern alloc] initWithPosX:centerJ posY:centerI estimatedModuleSize:estimatedModuleSize] autorelease];
      }
    }

    ZXResultPoint * point = [[[ZXAlignmentPattern alloc] initWithPosX:centerJ posY:centerI estimatedModuleSize:estimatedModuleSize] autorelease];
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
//  free(crossCheckStateCount);
  [resultPointCallback release];
  [super dealloc];
}

@end
