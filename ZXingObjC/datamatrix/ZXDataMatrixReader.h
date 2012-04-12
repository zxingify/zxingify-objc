#import "ZXReader.h"

/**
 * This implementation can detect and decode Data Matrix codes in an image.
 * 
 * @author bbrown@google.com (Brian Brown)
 */

@class ZXBinaryBitmap, ZXDataMatrixDecoder, ZXResult;

@interface ZXDataMatrixReader : NSObject <ZXReader> {
  ZXDataMatrixDecoder * decoder;
}

- (ZXResult *) decode:(ZXBinaryBitmap *)image;
- (ZXResult *) decode:(ZXBinaryBitmap *)image hints:(NSMutableDictionary *)hints;
- (void) reset;

@end
