#import "BarcodeFormat.h"
#import "BinaryBitmap.h"
#import "DecodeHintType.h"
#import "FormatException.h"
#import "NotFoundException.h"
#import "Reader.h"
#import "Result.h"
#import "ResultPoint.h"
#import "BitMatrix.h"
#import "DecoderResult.h"
#import "DetectorResult.h"
#import "Decoder.h"
#import "Detector.h"

/**
 * This implementation can detect and decode PDF417 codes in an image.
 * 
 * @author SITA Lab (kevin.osullivan@sita.aero)
 */

@interface PDF417Reader : NSObject <Reader> {
  Decoder * decoder;
}

- (void) init;
- (Result *) decode:(BinaryBitmap *)image;
- (Result *) decode:(BinaryBitmap *)image hints:(NSMutableDictionary *)hints;
- (void) reset;
@end
