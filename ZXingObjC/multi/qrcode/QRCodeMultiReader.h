#import "MultipleBarcodeReader.h"
#import "QRCodeReader.h"

/**
 * This implementation can detect and decode multiple QR Codes in an image.
 * 
 * @author Sean Owen
 * @author Hannes Erven
 */

@interface QRCodeMultiReader : QRCodeReader <MultipleBarcodeReader>

@end
