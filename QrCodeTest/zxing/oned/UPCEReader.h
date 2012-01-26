#import "BarcodeFormat.h"
#import "ChecksumException.h"
#import "FormatException.h"
#import "NotFoundException.h"
#import "BitArray.h"

/**
 * <p>Implements decoding of the UPC-E format.</p>
 * <p/>
 * <p><a href="http://www.barcodeisland.com/upce.phtml">This</a> is a great reference for
 * UPC-E information.</p>
 * 
 * @author Sean Owen
 */

@interface UPCEReader : UPCEANReader {
  NSArray * decodeMiddleCounters;
}

- (id) init;
- (int) decodeMiddle:(BitArray *)row startRange:(NSArray *)startRange result:(StringBuffer *)result;
- (NSArray *) decodeEnd:(BitArray *)row endStart:(int)endStart;
- (BOOL) checkChecksum:(NSString *)s;
- (BarcodeFormat *) getBarcodeFormat;
+ (NSString *) convertUPCEtoUPCA:(NSString *)upce;
@end
