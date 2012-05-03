#import "ZXReader.h"

/**
 * This implementation can detect and decode Data Matrix codes in an image.
 * 
 * @author bbrown@google.com (Brian Brown)
 */

@class ZXBinaryBitmap, ZXDataMatrixDecoder, ZXDecodeHints, ZXResult;

@interface ZXDataMatrixReader : NSObject <ZXReader> {
  ZXDataMatrixDecoder * decoder;
}

- (ZXResult *) decode:(ZXBinaryBitmap *)image;
- (ZXResult *) decode:(ZXBinaryBitmap *)image hints:(ZXDecodeHints *)hints;
- (void) reset;

@end
