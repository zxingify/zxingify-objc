#import "BitMatrix.h"
#import "DecodeHintType.h"
#import "FinderPatternInfo.h"
#import "MultiFinderPatternFinder.h"
#import "NotFoundException.h"
#import "QRCodeFinderPattern.h"

// TODO MIN_MODULE_COUNT and MAX_MODULE_COUNT would be great hints to ask the user for
// since it limits the number of regions to decode

// max. legal count of modules per QR code edge (177)
float const MAX_MODULE_COUNT_PER_EDGE = 180;
// min. legal count per modules per QR code edge (11)
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


@interface MultiFinderPatternFinder ()

NSInteger moduleSizeCompare(id center1, id center2, void *context);

@end


@implementation MultiFinderPatternFinder

/**
 * @return the 3 best {@link FinderPattern}s from our list of candidates. The "best" are
 * those that have been detected at least {@link #CENTER_QUORUM} times, and whose module
 * size differs from the average among those patterns the least
 * @throws NotFoundException if 3 such finder patterns do not exist
 */
- (NSArray *) selectBestPatterns {
  NSMutableArray *_possibleCenters = [NSMutableArray arrayWithArray:[self possibleCenters]];
  int size = [_possibleCenters count];

  if (size < 3) {
    @throw [NotFoundException notFoundInstance];
  }

  /*
   * Begin HE modifications to safely detect multiple codes of equal size
   */
  if (size == 3) {
    return [NSArray arrayWithObjects:[NSArray arrayWithObjects:[_possibleCenters objectAtIndex:0],
                                      [_possibleCenters objectAtIndex:1],
                                      [_possibleCenters objectAtIndex:2], nil], nil];
  }

  [_possibleCenters sortUsingFunction:moduleSizeCompare context:nil];

  /*
   * Now lets start: build a list of tuples of three finder locations that
   *  - feature similar module sizes
   *  - are placed in a distance so the estimated module count is within the QR specification
   *  - have similar distance between upper left/right and left top/bottom finder patterns
   *  - form a triangle with 90° angle (checked by comparing top right/bottom left distance
   *    with pythagoras)
   *
   * Note: we allow each point to be used for more than one code region: this might seem
   * counterintuitive at first, but the performance penalty is not that big. At this point,
   * we cannot make a good quality decision whether the three finders actually represent
   * a QR code, or are just by chance layouted so it looks like there might be a QR code there.
   * So, if the layout seems right, lets have the decoder try to decode.     
   */

  NSMutableArray * results = [NSMutableArray array];

  for (int i1 = 0; i1 < (size - 2); i1++) {
    QRCodeFinderPattern * p1 = [possibleCenters objectAtIndex:i1];
    if (p1 == nil) {
      continue;
    }

    for (int i2 = i1 + 1; i2 < (size - 1); i2++) {
      QRCodeFinderPattern * p2 = [possibleCenters objectAtIndex:i2];
      if (p2 == nil) {
        continue;
      }

      float vModSize12 = ([p1 estimatedModuleSize] - [p2 estimatedModuleSize]) / MIN([p1 estimatedModuleSize], [p2 estimatedModuleSize]);
      float vModSize12A = abs([p1 estimatedModuleSize] - [p2 estimatedModuleSize]);
      if (vModSize12A > DIFF_MODSIZE_CUTOFF && vModSize12 >= DIFF_MODSIZE_CUTOFF_PERCENT) {
        break;
      }

      for (int i3 = i2 + 1; i3 < size; i3++) {
        QRCodeFinderPattern * p3 = [possibleCenters objectAtIndex:i3];
        if (p3 == nil) {
          continue;
        }

        float vModSize23 = ([p2 estimatedModuleSize] - [p3 estimatedModuleSize]) / MIN([p2 estimatedModuleSize], [p3 estimatedModuleSize]);
        float vModSize23A = abs([p2 estimatedModuleSize] - [p3 estimatedModuleSize]);
        if (vModSize23A > DIFF_MODSIZE_CUTOFF && vModSize23 >= DIFF_MODSIZE_CUTOFF_PERCENT) {
          break;
        }

        NSMutableArray * test = [NSMutableArray arrayWithObjects:p1, p2, p3, nil];
        [ResultPoint orderBestPatterns:test];

        FinderPatternInfo * info = [[[FinderPatternInfo alloc] initWithPatternCenters:test] autorelease];
        float dA = [ResultPoint distance:[info topLeft] pattern2:[info bottomLeft]];
        float dC = [ResultPoint distance:[info topRight] pattern2:[info bottomLeft]];
        float dB = [ResultPoint distance:[info topLeft] pattern2:[info topRight]];

        float estimatedModuleCount = (dA + dB) / ([p1 estimatedModuleSize] * 2.0f);
        if (estimatedModuleCount > MAX_MODULE_COUNT_PER_EDGE || estimatedModuleCount < MIN_MODULE_COUNT_PER_EDGE) {
          continue;
        }

        float vABBC = abs((dA - dB) / MIN(dA, dB));
        if (vABBC >= 0.1f) {
          continue;
        }

        float dCpy = (float)sqrt(dA * dA + dB * dB);
        float vPyC = abs((dC - dCpy) / MIN(dC, dCpy));

        if (vPyC >= 0.1f) {
          continue;
        }

        [results addObject:test];
      }
    }
  }

  if ([results count] > 0) {
    return results;
  }

  @throw [NotFoundException notFoundInstance];
}

- (NSArray *) findMulti:(NSMutableDictionary *)hints {
  BOOL tryHarder = hints != nil && [hints objectForKey:[NSNumber numberWithInt:kDecodeHintTypeTryHarder]];
  int maxI = [image height];
  int maxJ = [image width];
  // We are looking for black/white/black/white/black modules in
  // 1:1:3:1:1 ratio; this tracks the number of such modules seen so far
  
  // Let's assume that the maximum version QR Code we support takes up 1/4 the height of the
  // image, and then account for the center being 3 modules in size. This gives the smallest
  // number of pixels the center could be, so skip this often. When trying harder, look for all
  // QR versions regardless of how dense they are.
  int iSkip = (int)(maxI / (MAX_MODULES * 4.0f) * 3);
  if (iSkip < MIN_SKIP || tryHarder) {
    iSkip = MIN_SKIP;
  }

  int stateCount[5];
  for (int i = iSkip - 1; i < maxI; i += iSkip) {
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
            if ([FinderPatternFinder foundPatternCross:stateCount]) {
              BOOL confirmed = [self handlePossibleCenter:stateCount i:i j:j];
              if (!confirmed) {
                do {
                  j++;
                } while (j < maxJ && ![image get:j y:i]);
                j--;
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

    if ([FinderPatternFinder foundPatternCross:stateCount]) {
      [self handlePossibleCenter:stateCount i:i j:maxJ];
    }
  }
  NSArray * patternInfo = [self selectBestPatterns];
  NSMutableArray * result = [NSMutableArray array];
  for (NSMutableArray * pattern in patternInfo) {
    [ResultPoint orderBestPatterns:pattern];
    [result addObject:[[[FinderPatternInfo alloc] initWithPatternCenters:pattern] autorelease]];
  }

  return result;
}

/**
 * A comparator that orders FinderPatterns by their estimated module size.
 */
NSInteger moduleSizeCompare(id center1, id center2, void *context) {
  float value = [((QRCodeFinderPattern *)center2) estimatedModuleSize] - [((QRCodeFinderPattern *)center1) estimatedModuleSize];
  return value < 0.0 ? -1 : value > 0.0 ? 1 : 0;
}

@end
