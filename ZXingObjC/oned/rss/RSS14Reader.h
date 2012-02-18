#import "AbstractRSSReader.h"

/**
 * Decodes RSS-14, including truncated and stacked variants. See ISO/IEC 24724:2006.
 */

@class BitArray, Result;

@interface RSS14Reader : AbstractRSSReader {
  NSMutableArray * possibleLeftPairs;
  NSMutableArray * possibleRightPairs;
}

- (Result *) decodeRow:(int)rowNumber row:(BitArray *)row hints:(NSMutableDictionary *)hints;

@end
