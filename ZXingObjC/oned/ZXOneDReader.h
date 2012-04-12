#import "ZXReader.h"

/**
 * Encapsulates functionality and implementation that is common to all families
 * of one-dimensional barcodes.
 * 
 * @author dswitkin@google.com (Daniel Switkin)
 * @author Sean Owen
 */

extern int const INTEGER_MATH_SHIFT;
extern int const PATTERN_MATCH_RESULT_SCALE_FACTOR;

@class ZXBitArray, ZXResult;

@interface ZXOneDReader : NSObject <ZXReader>

+ (void) recordPattern:(ZXBitArray *)row start:(int)start counters:(int[])counters;
+ (void) recordPatternInReverse:(ZXBitArray *)row start:(int)start counters:(int[])counters;
+ (int) patternMatchVariance:(int[])counters pattern:(int[])pattern maxIndividualVariance:(int)maxIndividualVariance;
- (ZXResult *) decodeRow:(int)rowNumber row:(ZXBitArray *)row hints:(NSMutableDictionary *)hints;

@end
