#import "ZXAbstractRSSReader.h"

/**
 * Decodes RSS-14, including truncated and stacked variants. See ISO/IEC 24724:2006.
 */

@class ZXResult;

@interface ZXRSS14Reader : ZXAbstractRSSReader {
  NSMutableArray * possibleLeftPairs;
  NSMutableArray * possibleRightPairs;
}

- (ZXResult *) decodeRow:(int)rowNumber row:(ZXBitArray *)row hints:(NSMutableDictionary *)hints;

@end
