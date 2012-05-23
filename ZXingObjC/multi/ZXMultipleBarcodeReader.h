#import "ZXBinaryBitmap.h"
#import "ZXResult.h"

/**
 * Implementation of this interface attempt to read several barcodes from one image.
 */

@class ZXDecodeHints;

@protocol ZXMultipleBarcodeReader <NSObject>

- (NSArray *)decodeMultiple:(ZXBinaryBitmap *)image error:(NSError**)error;
- (NSArray *)decodeMultiple:(ZXBinaryBitmap *)image hints:(ZXDecodeHints *)hints error:(NSError**)error;

@end
