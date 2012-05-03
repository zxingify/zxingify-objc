#import "ZXReader.h"

/**
 * This class attempts to decode a barcode from an image, not by scanning the whole image,
 * but by scanning subsets of the image. This is important when there may be multiple barcodes in
 * an image, and detecting a barcode may find parts of multiple barcode and fail to decode
 * (e.g. QR Codes). Instead this scans the four quadrants of the image -- and also the center
 * 'quadrant' to cover the case where a barcode is found in the center.
 * 
 * @see ZXGenericMultipleBarcodeReader
 */

@class ZXBinaryBitmap, ZXDecodeHints, ZXResult;

@interface ZXByQuadrantReader : NSObject <ZXReader> {
  id<ZXReader> delegate;
}

- (id) initWithDelegate:(id<ZXReader>)delegate;
- (ZXResult *) decode:(ZXBinaryBitmap *)image;
- (ZXResult *) decode:(ZXBinaryBitmap *)image hints:(ZXDecodeHints *)hints;
- (void) reset;

@end
