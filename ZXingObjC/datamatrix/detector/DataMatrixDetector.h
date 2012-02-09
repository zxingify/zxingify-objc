#import "NotFoundException.h"
#import "ResultPoint.h"
#import "BitMatrix.h"
#import "Collections.h"
#import "Comparator.h"
#import "DetectorResult.h"
#import "GridSampler.h"
#import "WhiteRectangleDetector.h"
#import "NSEnumerator.h"

/**
 * Simply encapsulates two points and a number of transitions between them.
 */

@interface ResultPointsAndTransitions : NSObject {
  ResultPoint * from;
  ResultPoint * to;
  int transitions;
}

@property(nonatomic, retain, readonly) ResultPoint * from;
@property(nonatomic, retain, readonly) ResultPoint * to;
@property(nonatomic, readonly) int transitions;
- (NSString *) description;
@end

/**
 * Orders ResultPointsAndTransitions by number of transitions, ascending.
 */

@interface ResultPointsAndTransitionsComparator : NSObject <Comparator> {
}

- (int) compare:(NSObject *)o1 o2:(NSObject *)o2;
@end

/**
 * <p>Encapsulates logic that can detect a Data Matrix Code in an image, even if the Data Matrix Code
 * is rotated or skewed, or partially obscured.</p>
 * 
 * @author Sean Owen
 */

@interface DataMatrixDetector : NSObject {
  BitMatrix * image;
  WhiteRectangleDetector * rectangleDetector;
}

- (id) initWithImage:(BitMatrix *)image;
- (DetectorResult *) detect;
@end
