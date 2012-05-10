#import "ZXReader.h"

/**
 * This implementation can detect and decode QR Codes in an image.
 */

@class ZXBinaryBitmap, ZXQRCodeDecoder, ZXResult;

@interface ZXQRCodeReader : NSObject <ZXReader>

@property (nonatomic, retain, readonly) ZXQRCodeDecoder * decoder;

@end
