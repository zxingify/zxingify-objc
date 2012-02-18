#import "Reader.h"

/**
 * MultiFormatReader is a convenience class and the main entry point into the library for most uses.
 * By default it attempts to decode all barcode formats that the library supports. Optionally, you
 * can provide a hints object to request different behavior, for example only decoding QR codes.
 * 
 * @author Sean Owen
 * @author dswitkin@google.com (Daniel Switkin)
 */

@interface MultiFormatReader : NSObject <Reader> {
  NSMutableDictionary * hints;
  NSMutableArray * readers;
}

- (Result *) decodeWithState:(BinaryBitmap *)image;
- (void) setHints:(NSMutableDictionary *)hints;

@end
