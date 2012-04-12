#import "ZXOneDReader.h"

/**
 * <p>Decodes Code 93 barcodes.</p>
 * 
 * @author Sean Owen
 * @see ZXCode39Reader
 */

@class ZXResult;

@interface ZXCode93Reader : ZXOneDReader

- (ZXResult *) decodeRow:(int)rowNumber row:(ZXBitArray *)row hints:(NSMutableDictionary *)hints;

@end
