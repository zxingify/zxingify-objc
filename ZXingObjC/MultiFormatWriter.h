#import "BitMatrix.h"
#import "Code128Writer.h"
#import "Code39Writer.h"
#import "EAN13Writer.h"
#import "EAN8Writer.h"
#import "ITFWriter.h"
#import "UPCAWriter.h"
#import "QRCodeWriter.h"

/**
 * This is a factory class which finds the appropriate Writer subclass for the BarcodeFormat
 * requested and encodes the barcode with the supplied contents.
 * 
 * @author dswitkin@google.com (Daniel Switkin)
 */

@interface MultiFormatWriter : NSObject <Writer>

- (BitMatrix *) encode:(NSString *)contents format:(BarcodeFormat *)format width:(int)width height:(int)height;
- (BitMatrix *) encode:(NSString *)contents format:(BarcodeFormat *)format width:(int)width height:(int)height hints:(NSMutableDictionary *)hints;

@end
