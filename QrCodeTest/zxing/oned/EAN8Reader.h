#import "BarcodeFormat.h"
#import "NotFoundException.h"
#import "BitArray.h"

/**
 * <p>Implements decoding of the EAN-8 format.</p>
 * 
 * @author Sean Owen
 */

@interface EAN8Reader : UPCEANReader {
  NSArray * decodeMiddleCounters;
}

- (id) init;
- (int) decodeMiddle:(BitArray *)row startRange:(NSArray *)startRange result:(StringBuffer *)result;
- (BarcodeFormat *) getBarcodeFormat;
@end
