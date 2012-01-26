#import "BarcodeFormat.h"
#import "BinaryBitmap.h"
#import "NotFoundException.h"
#import "ReaderException.h"
#import "Result.h"
#import "ResultMetadataType.h"
#import "ResultPoint.h"
#import "DecoderResult.h"
#import "DetectorResult.h"
#import "MultipleBarcodeReader.h"
#import "MultiDetector.h"
#import "QRCodeReader.h"
#import "NSMutableDictionary.h"
#import "NSMutableArray.h"

/**
 * This implementation can detect and decode multiple QR Codes in an image.
 * 
 * @author Sean Owen
 * @author Hannes Erven
 */

@interface QRCodeMultiReader : QRCodeReader <MultipleBarcodeReader> {
}

- (NSArray *) decodeMultiple:(BinaryBitmap *)image;
- (NSArray *) decodeMultiple:(BinaryBitmap *)image hints:(NSMutableDictionary *)hints;
@end
