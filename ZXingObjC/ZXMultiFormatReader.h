#import "ZXReader.h"

/**
 * ZXMultiFormatReader is a convenience class and the main entry point into the library for most uses.
 * By default it attempts to decode all barcode formats that the library supports. Optionally, you
 * can provide a hints object to request different behavior, for example only decoding QR codes.
 */

@class ZXDecodeHints;

@interface ZXMultiFormatReader : NSObject <ZXReader>

@property (nonatomic, retain) ZXDecodeHints * hints;

+ (ZXMultiFormatReader*)reader;
- (ZXResult *)decodeWithState:(ZXBinaryBitmap *)image error:(NSError **)error;

@end
