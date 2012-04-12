#import "ZXBarcodeFormat.h"

/**
 * The base class for all objects which encode/generate a barcode image.
 * 
 * @author dswitkin@google.com (Daniel Switkin)
 */

@class ZXBitMatrix;

@protocol ZXWriter <NSObject>

- (ZXBitMatrix *) encode:(NSString *)contents format:(ZXBarcodeFormat)format width:(int)width height:(int)height;
- (ZXBitMatrix *) encode:(NSString *)contents format:(ZXBarcodeFormat)format width:(int)width height:(int)height hints:(NSMutableDictionary *)hints;

@end
