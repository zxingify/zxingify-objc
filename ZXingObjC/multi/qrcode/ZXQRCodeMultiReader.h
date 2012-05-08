#import "ZXMultipleBarcodeReader.h"
#import "ZXQRCodeReader.h"

/**
 * This implementation can detect and decode multiple QR Codes in an image.
 */

@interface ZXQRCodeMultiReader : ZXQRCodeReader <ZXMultipleBarcodeReader>

@end
