#import "ZXReader.h"

/**
 * This implementation can detect and decode QR Codes in an image.
 * 
 * @author Sean Owen
 */

@class ZXBinaryBitmap, ZXQRCodeDecoder, ZXResult;

@interface ZXQRCodeReader : NSObject <ZXReader> {
  ZXQRCodeDecoder * decoder;
}

@property (nonatomic, readonly) ZXQRCodeDecoder * decoder;

@end
