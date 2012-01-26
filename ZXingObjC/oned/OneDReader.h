#import "BinaryBitmap.h"
#import "ChecksumException.h"
#import "DecodeHintType.h"
#import "FormatException.h"
#import "NotFoundException.h"
#import "Reader.h"
#import "ReaderException.h"
#import "Result.h"
#import "ResultMetadataType.h"
#import "ResultPoint.h"
#import "BitArray.h"
#import "NSEnumerator.h"
#import "NSMutableDictionary.h"

/**
 * Encapsulates functionality and implementation that is common to all families
 * of one-dimensional barcodes.
 * 
 * @author dswitkin@google.com (Daniel Switkin)
 * @author Sean Owen
 */

@interface OneDReader : NSObject <Reader> {
}

- (Result *) decode:(BinaryBitmap *)image;
- (Result *) decode:(BinaryBitmap *)image hints:(NSMutableDictionary *)hints;
- (void) reset;
+ (void) recordPattern:(BitArray *)row start:(int)start counters:(NSArray *)counters;
+ (void) recordPatternInReverse:(BitArray *)row start:(int)start counters:(NSArray *)counters;
+ (int) patternMatchVariance:(NSArray *)counters pattern:(NSArray *)pattern maxIndividualVariance:(int)maxIndividualVariance;
- (Result *) decodeRow:(int)rowNumber row:(BitArray *)row hints:(NSMutableDictionary *)hints;
@end
