#import "ZXOneDReader.h"

/**
 * <p>Decodes Codabar barcodes.</p>
 * 
 * @author Bas Vijfwinkel
 */

@class ZXBitArray, ZXResult;

@interface ZXCodaBarReader : ZXOneDReader

- (ZXResult *) decodeRow:(int)rowNumber row:(ZXBitArray *)row hints:(NSMutableDictionary *)hints;

@end
