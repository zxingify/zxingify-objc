#import "ZXReader.h"

@class ZXBinaryBitmap, ZXDecodeHints, ZXResult;

@interface ZXAztecReader : NSObject <ZXReader>

- (ZXResult *)decode:(ZXBinaryBitmap *)image;
- (ZXResult *)decode:(ZXBinaryBitmap *)image hints:(ZXDecodeHints *)hints;
- (void)reset;

@end
