#import "ZXReader.h"

/**
 * This implementation can detect and decode Data Matrix codes in an image.
 */

@class ZXBinaryBitmap, ZXDecodeHints, ZXResult;

@interface ZXDataMatrixReader : NSObject <ZXReader>

- (ZXResult *)decode:(ZXBinaryBitmap *)image;
- (ZXResult *)decode:(ZXBinaryBitmap *)image hints:(ZXDecodeHints *)hints;
- (void)reset;

@end
