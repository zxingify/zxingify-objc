#import "ZXMultipleBarcodeReader.h"
#import "ZXQRCodeReader.h"

/**
 * This implementation can detect and decode multiple QR Codes in an image.
 * 
 * @author Sean Owen
 * @author Hannes Erven
 */

@interface ZXQRCodeMultiReader : ZXQRCodeReader <ZXMultipleBarcodeReader>

@end
