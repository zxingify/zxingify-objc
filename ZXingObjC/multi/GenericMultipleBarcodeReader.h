#import "MultipleBarcodeReader.h"

/**
 * <p>Attempts to locate multiple barcodes in an image by repeatedly decoding portion of the image.
 * After one barcode is found, the areas left, above, right and below the barcode's
 * {@link com.google.zxing.ResultPoint}s are scanned, recursively.</p>
 * 
 * <p>A caller may want to also employ {@link ByQuadrantReader} when attempting to find multiple
 * 2D barcodes, like QR Codes, in an image, where the presence of multiple barcodes might prevent
 * detecting any one of them.</p>
 * 
 * <p>That is, instead of passing a {@link Reader} a caller might pass
 * <code>new ByQuadrantReader(reader)</code>.</p>
 * 
 * @author Sean Owen
 */

@protocol Reader;

@interface GenericMultipleBarcodeReader : NSObject <MultipleBarcodeReader> {
  id <Reader> delegate;
}

- (id) initWithDelegate:(id <Reader>)delegate;
- (NSArray *) decodeMultiple:(BinaryBitmap *)image;
- (NSArray *) decodeMultiple:(BinaryBitmap *)image hints:(NSMutableDictionary *)hints;

@end
