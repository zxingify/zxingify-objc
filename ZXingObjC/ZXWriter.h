#import "ZXBarcodeFormat.h"

/**
 * The base class for all objects which encode/generate a barcode image.
 */

@class ZXBitMatrix, ZXEncodeHints;

@protocol ZXWriter <NSObject>

- (ZXBitMatrix *)encode:(NSString *)contents format:(ZXBarcodeFormat)format width:(int)width height:(int)height error:(NSError**)error;
- (ZXBitMatrix *)encode:(NSString *)contents format:(ZXBarcodeFormat)format width:(int)width height:(int)height hints:(ZXEncodeHints *)hints error:(NSError**)error;

@end
