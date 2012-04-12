#import "ZXMultipleBarcodeReader.h"

/**
 * <p>Attempts to locate multiple barcodes in an image by repeatedly decoding portion of the image.
 * After one barcode is found, the areas left, above, right and below the barcode's
 * {@link com.google.zxing.ResultPoint}s are scanned, recursively.</p>
 * 
 * <p>A caller may want to also employ {@link ZXByQuadrantReader} when attempting to find multiple
 * 2D barcodes, like QR Codes, in an image, where the presence of multiple barcodes might prevent
 * detecting any one of them.</p>
 * 
 * <p>That is, instead of passing a {@link Reader} a caller might pass
 * <code>new ZXByQuadrantReader(reader)</code>.</p>
 * 
 * @author Sean Owen
 */

@protocol ZXReader;

@interface ZXGenericMultipleBarcodeReader : NSObject <ZXMultipleBarcodeReader> {
  id <ZXReader> delegate;
}

- (id) initWithDelegate:(id <ZXReader>)delegate;
- (NSArray *) decodeMultiple:(ZXBinaryBitmap *)image;
- (NSArray *) decodeMultiple:(ZXBinaryBitmap *)image hints:(NSMutableDictionary *)hints;

@end
