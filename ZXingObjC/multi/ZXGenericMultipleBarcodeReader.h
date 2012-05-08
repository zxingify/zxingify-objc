#import "ZXMultipleBarcodeReader.h"

/**
 * Attempts to locate multiple barcodes in an image by repeatedly decoding portion of the image.
 * After one barcode is found, the areas left, above, right and below the barcode's
 * ZXResultPoints are scanned, recursively.
 * 
 * A caller may want to also employ ZXByQuadrantReader when attempting to find multiple
 * 2D barcodes, like QR Codes, in an image, where the presence of multiple barcodes might prevent
 * detecting any one of them.
 * 
 * That is, instead of passing an ZXReader a caller might pass
 * [[ZXByQuadrantReader alloc] initWithDelegate:reader]</code>.
 */

@protocol ZXReader;

@interface ZXGenericMultipleBarcodeReader : NSObject <ZXMultipleBarcodeReader>

- (id)initWithDelegate:(id<ZXReader>)delegate;

@end
