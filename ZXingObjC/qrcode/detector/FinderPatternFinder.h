/**
 * <p>This class attempts to find finder patterns in a QR Code. Finder patterns are the square
 * markers at three corners of a QR Code.</p>
 * 
 * <p>This class is thread-safe but not reentrant. Each thread must allocate its own object.
 * 
 * @author Sean Owen
 */

@class BitMatrix, FinderPatternInfo;
@protocol ResultPointCallback;

@interface FinderPatternFinder : NSObject {
  BitMatrix * image;
  NSMutableArray * possibleCenters;
  BOOL hasSkipped;
  int crossCheckStateCount[5];
  id <ResultPointCallback> resultPointCallback;
}

@property (nonatomic, readonly) BitMatrix * image;
@property (nonatomic, readonly) NSMutableArray * possibleCenters;

- (id) initWithImage:(BitMatrix *)image;
- (id) initWithImage:(BitMatrix *)image resultPointCallback:(id <ResultPointCallback>)resultPointCallback;
- (FinderPatternInfo *) find:(NSMutableDictionary *)hints;
+ (BOOL) foundPatternCross:(int[])stateCount;
- (BOOL) handlePossibleCenter:(int[])stateCount i:(int)i j:(int)j;

@end
