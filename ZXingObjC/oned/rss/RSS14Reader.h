#import "BarcodeFormat.h"
#import "DecodeHintType.h"
#import "NotFoundException.h"
#import "Result.h"
#import "ResultPoint.h"
#import "ResultPointCallback.h"
#import "BitArray.h"
#import "NSEnumerator.h"
#import "NSMutableDictionary.h"
#import "NSMutableArray.h"

/**
 * Decodes RSS-14, including truncated and stacked variants. See ISO/IEC 24724:2006.
 */

@interface RSS14Reader : AbstractRSSReader {
  NSMutableArray * possibleLeftPairs;
  NSMutableArray * possibleRightPairs;
}

- (id) init;
- (Result *) decodeRow:(int)rowNumber row:(BitArray *)row hints:(NSMutableDictionary *)hints;
- (void) reset;
@end
