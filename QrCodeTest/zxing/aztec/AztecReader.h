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
#import "ResultPointCallback.h"
#import "DecoderResult.h"
#import "Decoder.h"
#import "Detector.h"
#import "NSMutableDictionary.h"

/**
 * This implementation can detect and decode Aztec codes in an image.
 * 
 * @author David Olivier
 */

@interface AztecReader : NSObject <Reader> {
}

- (Result *) decode:(BinaryBitmap *)image;
- (Result *) decode:(BinaryBitmap *)image hints:(NSMutableDictionary *)hints;
- (void) reset;
@end
