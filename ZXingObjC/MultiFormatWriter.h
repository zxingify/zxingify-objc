#import "Writer.h"

/**
 * This is a factory class which finds the appropriate Writer subclass for the BarcodeFormat
 * requested and encodes the barcode with the supplied contents.
 * 
 * @author dswitkin@google.com (Daniel Switkin)
 */

@interface MultiFormatWriter : NSObject <Writer>

@end
