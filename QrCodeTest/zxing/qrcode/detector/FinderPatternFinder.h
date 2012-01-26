#import "DecodeHintType.h"
#import "NotFoundException.h"
#import "ResultPoint.h"
#import "ResultPointCallback.h"
#import "BitMatrix.h"
#import "Collections.h"
#import "Comparator.h"
#import "NSMutableDictionary.h"
#import "NSMutableArray.h"

/**
 * <p>Orders by furthest from average</p>
 */

@interface FurthestFromAverageComparator : NSObject <Comparator> {
  float average;
}

- (int) compare:(NSObject *)center1 center2:(NSObject *)center2;
@end

/**
 * <p>Orders by {@link FinderPattern#getCount()}, descending.</p>
 */

@interface CenterComparator : NSObject <Comparator> {
  float average;
}

- (int) compare:(NSObject *)center1 center2:(NSObject *)center2;
@end

/**
 * <p>This class attempts to find finder patterns in a QR Code. Finder patterns are the square
 * markers at three corners of a QR Code.</p>
 * 
 * <p>This class is thread-safe but not reentrant. Each thread must allocate its own object.
 * 
 * @author Sean Owen
 */

@interface FinderPatternFinder : NSObject {
  BitMatrix * image;
  NSMutableArray * possibleCenters;
  BOOL hasSkipped;
  NSArray * crossCheckStateCount;
  ResultPointCallback * resultPointCallback;
}

- (id) initWithImage:(BitMatrix *)image;
- (id) init:(BitMatrix *)image resultPointCallback:(ResultPointCallback *)resultPointCallback;
- (BitMatrix *) getImage;
- (NSMutableArray *) getPossibleCenters;
- (FinderPatternInfo *) find:(NSMutableDictionary *)hints;
+ (BOOL) foundPatternCross:(NSArray *)stateCount;
- (BOOL) handlePossibleCenter:(NSArray *)stateCount i:(int)i j:(int)j;
@end
