#import "BarcodeFormat.h"
#import "NotFoundException.h"
#import "BitArray.h"

/**
 * <p>Implements decoding of the EAN-13 format.</p>
 * 
 * @author dswitkin@google.com (Daniel Switkin)
 * @author Sean Owen
 * @author alasdair@google.com (Alasdair Mackintosh)
 */

@interface EAN13Reader : UPCEANReader {
  NSArray * decodeMiddleCounters;
}

- (id) init;
- (int) decodeMiddle:(BitArray *)row startRange:(NSArray *)startRange resultString:(StringBuffer *)resultString;
- (BarcodeFormat *) getBarcodeFormat;
@end
