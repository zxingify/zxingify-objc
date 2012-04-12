#import "ZXReader.h"

/**
 * This implementation can detect and decode Aztec codes in an image.
 * 
 * @author David Olivier
 */

@class ZXBinaryBitmap, ZXResult;

@interface ZXAztecReader : NSObject <ZXReader>

- (ZXResult *)decode:(ZXBinaryBitmap *)image;
- (ZXResult *)decode:(ZXBinaryBitmap *)image hints:(NSMutableDictionary *)hints;
- (void)reset;

@end
