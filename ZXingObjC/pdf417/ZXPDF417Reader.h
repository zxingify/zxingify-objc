#import "ZXReader.h"

/**
 * This implementation can detect and decode PDF417 codes in an image.
 * 
 * @author SITA Lab (kevin.osullivan@sita.aero)
 */

@class ZXDecodeHints, ZXPDF417Decoder, ZXResult;

@interface ZXPDF417Reader : NSObject <ZXReader> {
  ZXPDF417Decoder * decoder;
}

- (ZXResult *) decode:(ZXBinaryBitmap *)image;
- (ZXResult *) decode:(ZXBinaryBitmap *)image hints:(ZXDecodeHints *)hints;
- (void) reset;

@end
