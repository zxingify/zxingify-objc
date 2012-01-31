#import "BarcodeFormat.h"
#import "UPCEANReader.h"

/**
 * <p>Implements decoding of the EAN-13 format.</p>
 * 
 * @author dswitkin@google.com (Daniel Switkin)
 * @author Sean Owen
 * @author alasdair@google.com (Alasdair Mackintosh)
 */

@class BitArray;

@interface EAN13Reader : UPCEANReader {
  NSArray * decodeMiddleCounters;
}

- (id) init;
- (int) decodeMiddle:(BitArray *)row startRange:(NSArray *)startRange resultString:(NSMutableString *)resultString;
- (BarcodeFormat) getBarcodeFormat;
@end
