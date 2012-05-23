#import "ZXReader.h"

/**
 * Encapsulates functionality and implementation that is common to all families
 * of one-dimensional barcodes.
 */

extern int const INTEGER_MATH_SHIFT;
extern int const PATTERN_MATCH_RESULT_SCALE_FACTOR;

@class ZXBitArray, ZXDecodeHints, ZXResult;

@interface ZXOneDReader : NSObject <ZXReader>

+ (BOOL)recordPattern:(ZXBitArray *)row start:(int)start counters:(int[])counters countersSize:(int)countersSize;
+ (BOOL)recordPatternInReverse:(ZXBitArray *)row start:(int)start counters:(int[])counters countersSize:(int)countersSize;
+ (int)patternMatchVariance:(int[])counters countersSize:(int)countersSize pattern:(int[])pattern maxIndividualVariance:(int)maxIndividualVariance;
- (ZXResult *)decodeRow:(int)rowNumber row:(ZXBitArray *)row hints:(ZXDecodeHints *)hints error:(NSError**)error;

@end
