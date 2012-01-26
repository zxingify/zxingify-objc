#import "BarcodeFormat.h"
#import "BinaryBitmap.h"
#import "ChecksumException.h"
#import "DecodeHintType.h"
#import "FormatException.h"
#import "NotFoundException.h"
#import "Reader.h"
#import "Result.h"
#import "ResultMetadataType.h"
#import "ResultPoint.h"
#import "BitMatrix.h"
#import "DecoderResult.h"
#import "DetectorResult.h"
#import "Decoder.h"
#import "Detector.h"
#import "NSMutableDictionary.h"

/**
 * This implementation can detect and decode Data Matrix codes in an image.
 * 
 * @author bbrown@google.com (Brian Brown)
 */

@interface DataMatrixReader : NSObject <Reader> {
  Decoder * decoder;
}

- (void) init;
- (Result *) decode:(BinaryBitmap *)image;
- (Result *) decode:(BinaryBitmap *)image hints:(NSMutableDictionary *)hints;
- (void) reset;
@end
