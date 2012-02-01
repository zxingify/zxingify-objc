#import "Reader.h"

/**
 * Encapsulates functionality and implementation that is common to all families
 * of one-dimensional barcodes.
 * 
 * @author dswitkin@google.com (Daniel Switkin)
 * @author Sean Owen
 */

@class BitArray, BinaryBitmap, Result;

@interface OneDReader : NSObject <Reader>

- (Result *) decode:(BinaryBitmap *)image;
- (Result *) decode:(BinaryBitmap *)image hints:(NSMutableDictionary *)hints;
- (void) reset;
+ (void) recordPattern:(BitArray *)row start:(int)start counters:(NSMutableArray *)counters;
+ (void) recordPatternInReverse:(BitArray *)row start:(int)start counters:(NSMutableArray *)counters;
+ (int) patternMatchVariance:(NSArray *)counters pattern:(NSArray *)pattern maxIndividualVariance:(int)maxIndividualVariance;
- (Result *) decodeRow:(int)rowNumber row:(BitArray *)row hints:(NSMutableDictionary *)hints;

@end
