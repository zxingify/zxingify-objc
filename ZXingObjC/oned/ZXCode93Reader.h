#import "ZXOneDReader.h"

/**
 * <p>Decodes Code 93 barcodes.</p>
 * 
 * @author Sean Owen
 * @see ZXCode39Reader
 */

@class ZXDecodeHints, ZXResult;

@interface ZXCode93Reader : ZXOneDReader

- (ZXResult *) decodeRow:(int)rowNumber row:(ZXBitArray *)row hints:(ZXDecodeHints *)hints;

@end
