#import "ZXReader.h"

/**
 * This implementation can detect and decode PDF417 codes in an image.
 */

@class ZXDecodeHints, ZXPDF417Decoder, ZXResult;

@interface ZXPDF417Reader : NSObject <ZXReader>

@end
