#import "Reader.h"

/**
 * This implementation can detect and decode PDF417 codes in an image.
 * 
 * @author SITA Lab (kevin.osullivan@sita.aero)
 */

@class PDF417Decoder, Result;

@interface PDF417Reader : NSObject <Reader> {
  PDF417Decoder * decoder;
}

- (Result *) decode:(BinaryBitmap *)image;
- (Result *) decode:(BinaryBitmap *)image hints:(NSMutableDictionary *)hints;
- (void) reset;

@end
