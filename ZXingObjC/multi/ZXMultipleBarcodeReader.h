#import "ZXBinaryBitmap.h"
#import "ZXNotFoundException.h"
#import "ZXResult.h"

/**
 * Implementation of this interface attempt to read several barcodes from one image.
 * 
 * @see com.google.zxing.Reader
 * @author Sean Owen
 */

@class ZXDecodeHints;

@protocol ZXMultipleBarcodeReader <NSObject>
- (NSArray *) decodeMultiple:(ZXBinaryBitmap *)image;
- (NSArray *) decodeMultiple:(ZXBinaryBitmap *)image hints:(ZXDecodeHints *)hints;
@end
