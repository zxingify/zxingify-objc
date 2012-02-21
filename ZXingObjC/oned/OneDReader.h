#import "Reader.h"

/**
 * Encapsulates functionality and implementation that is common to all families
 * of one-dimensional barcodes.
 * 
 * @author dswitkin@google.com (Daniel Switkin)
 * @author Sean Owen
 */

extern int const INTEGER_MATH_SHIFT;
extern int const PATTERN_MATCH_RESULT_SCALE_FACTOR;

@class BitArray, BinaryBitmap, Result;

@interface OneDReader : NSObject <Reader>

+ (void) recordPattern:(BitArray *)row start:(int)start counters:(int[])counters;
+ (void) recordPatternInReverse:(BitArray *)row start:(int)start counters:(int[])counters;
+ (int) patternMatchVariance:(int[])counters pattern:(int[])pattern maxIndividualVariance:(int)maxIndividualVariance;
- (Result *) decodeRow:(int)rowNumber row:(BitArray *)row hints:(NSMutableDictionary *)hints;

@end
