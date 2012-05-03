#import "ZXOneDReader.h"

/**
 * <p>Decodes Code 128 barcodes.</p>
 * 
 * @author Sean Owen
 */

extern const int CODE_PATTERNS[][7];

@class ZXDecodeHints, ZXResult;

@interface ZXCode128Reader : ZXOneDReader

- (ZXResult *) decodeRow:(int)rowNumber row:(ZXBitArray *)row hints:(ZXDecodeHints *)hints;

@end
