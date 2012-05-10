/**
 * This class attempts to find finder patterns in a QR Code. Finder patterns are the square
 * markers at three corners of a QR Code.
 * 
 * This class is thread-safe but not reentrant. Each thread must allocate its own object.
 */

extern int const FINDER_PATTERN_MIN_SKIP;
extern int const FINDER_PATTERN_MAX_MODULES;

@class ZXBitMatrix, ZXDecodeHints, ZXFinderPatternInfo;
@protocol ZXResultPointCallback;

@interface ZXFinderPatternFinder : NSObject

@property (nonatomic, retain, readonly) ZXBitMatrix * image;
@property (nonatomic, retain, readonly) NSMutableArray * possibleCenters;

- (id) initWithImage:(ZXBitMatrix *)image;
- (id) initWithImage:(ZXBitMatrix *)image resultPointCallback:(id <ZXResultPointCallback>)resultPointCallback;
- (ZXFinderPatternInfo *) find:(ZXDecodeHints *)hints;
+ (BOOL) foundPatternCross:(int[])stateCount;
- (BOOL) handlePossibleCenter:(int[])stateCount i:(int)i j:(int)j;

@end
