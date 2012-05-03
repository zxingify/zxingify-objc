#import "ZXOneDReader.h"

/**
 * <p>Decodes Codabar barcodes.</p>
 * 
 * @author Bas Vijfwinkel
 */

@class ZXBitArray, ZXDecodeHints, ZXResult;

@interface ZXCodaBarReader : ZXOneDReader

- (ZXResult *) decodeRow:(int)rowNumber row:(ZXBitArray *)row hints:(ZXDecodeHints *)hints;

@end
