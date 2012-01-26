#import "BitMatrix.h"

/**
 * The base class for all objects which encode/generate a barcode image.
 * 
 * @author dswitkin@google.com (Daniel Switkin)
 */

@protocol Writer <NSObject>
- (BitMatrix *) encode:(NSString *)contents format:(BarcodeFormat *)format width:(int)width height:(int)height;
- (BitMatrix *) encode:(NSString *)contents format:(BarcodeFormat *)format width:(int)width height:(int)height hints:(NSMutableDictionary *)hints;
@end
