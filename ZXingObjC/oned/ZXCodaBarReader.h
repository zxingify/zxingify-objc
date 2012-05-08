#import "ZXOneDReader.h"

/**
 * Decodes Codabar barcodes.
 */

@class ZXBitArray, ZXDecodeHints, ZXResult;

@interface ZXCodaBarReader : ZXOneDReader

- (ZXResult *)decodeRow:(int)rowNumber row:(ZXBitArray *)row hints:(ZXDecodeHints *)hints;

@end
