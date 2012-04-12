#import "ZXReader.h"

/**
 * ZXMultiFormatReader is a convenience class and the main entry point into the library for most uses.
 * By default it attempts to decode all barcode formats that the library supports. Optionally, you
 * can provide a hints object to request different behavior, for example only decoding QR codes.
 * 
 * @author Sean Owen
 * @author dswitkin@google.com (Daniel Switkin)
 */

@interface ZXMultiFormatReader : NSObject <ZXReader> {
  NSMutableDictionary * hints;
  NSMutableArray * readers;
}

- (ZXResult *) decodeWithState:(ZXBinaryBitmap *)image;
- (void) setHints:(NSMutableDictionary *)hints;

@end
