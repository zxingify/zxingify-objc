#import "ZXBinaryBitmap.h"
#import "ZXResult.h"

/**
 * Implementations of this interface can decode an image of a barcode in some format into
 * the String it encodes. For example, {@link com.google.zxing.qrcode.QRCodeReader} can
 * decode a QR code. The decoder may optionally receive hints from the caller which may help
 * it decode more quickly or accurately.
 * 
 * See {@link com.google.zxing.ZXMultiFormatReader}, which attempts to determine what barcode
 * format is present within the image as well, and then decodes it accordingly.
 * 
 * @author Sean Owen
 * @author dswitkin@google.com (Daniel Switkin)
 */

@class ZXDecodeHints;

@protocol ZXReader <NSObject>

- (ZXResult *) decode:(ZXBinaryBitmap *)image;
- (ZXResult *) decode:(ZXBinaryBitmap *)image hints:(ZXDecodeHints *)hints;
- (void) reset;

@end
