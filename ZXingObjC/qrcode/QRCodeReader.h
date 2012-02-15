#import "Reader.h"

/**
 * This implementation can detect and decode QR Codes in an image.
 * 
 * @author Sean Owen
 */

@class BinaryBitmap, Decoder, Result;

@interface QRCodeReader : NSObject <Reader> {
  Decoder * decoder;
}

- (Decoder *) getDecoder;
- (Result *) decode:(BinaryBitmap *)image;
- (Result *) decode:(BinaryBitmap *)image hints:(NSMutableDictionary *)hints;
- (void) reset;

@end
