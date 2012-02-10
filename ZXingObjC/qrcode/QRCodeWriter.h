#import "BarcodeFormat.h"
#import "EncodeHintType.h"
#import "Writer.h"
#import "WriterException.h"
#import "BitMatrix.h"
#import "ByteMatrix.h"
#import "ErrorCorrectionLevel.h"
#import "QRCodeEncoder.h"
#import "QRCode.h"

/**
 * This object renders a QR Code as a BitMatrix 2D array of greyscale values.
 * 
 * @author dswitkin@google.com (Daniel Switkin)
 */

@interface QRCodeWriter : NSObject <Writer>

- (BitMatrix *) encode:(NSString *)contents format:(BarcodeFormat *)format width:(int)width height:(int)height;
- (BitMatrix *) encode:(NSString *)contents format:(BarcodeFormat *)format width:(int)width height:(int)height hints:(NSMutableDictionary *)hints;

@end
