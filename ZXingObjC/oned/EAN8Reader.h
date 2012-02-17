#import "BarcodeFormat.h"
#import "UPCEANReader.h"

/**
 * <p>Implements decoding of the EAN-8 format.</p>
 * 
 * @author Sean Owen
 */

@interface EAN8Reader : UPCEANReader {
  NSArray * decodeMiddleCounters;
}

- (id) init;
- (int) decodeMiddle:(BitArray *)row startRange:(NSArray *)startRange result:(NSMutableString *)result;
- (BarcodeFormat *) getBarcodeFormat;
@end
