#import "Reader.h"

/**
 * This implementation can detect and decode QR Codes in an image.
 * 
 * @author Sean Owen
 */

@class BinaryBitmap, QRCodeDecoder, Result;

@interface QRCodeReader : NSObject <Reader> {
  QRCodeDecoder * decoder;
}

@property (nonatomic, readonly) QRCodeDecoder * decoder;

@end
