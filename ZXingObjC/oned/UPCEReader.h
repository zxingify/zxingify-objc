#import "BarcodeFormat.h"
#import "UPCEANReader.h"

/**
 * <p>Implements decoding of the UPC-E format.</p>
 * <p/>
 * <p><a href="http://www.barcodeisland.com/upce.phtml">This</a> is a great reference for
 * UPC-E information.</p>
 * 
 * @author Sean Owen
 */

@class BitArray;

@interface UPCEReader : UPCEANReader {
  int decodeMiddleCounters[4];
}

@property (nonatomic, readonly) BarcodeFormat barcodeFormat;

- (int) decodeMiddle:(BitArray *)row startRange:(NSArray *)startRange result:(NSMutableString *)result;
- (NSArray *) decodeEnd:(BitArray *)row endStart:(int)endStart;
- (BOOL) checkChecksum:(NSString *)s;
+ (NSString *) convertUPCEtoUPCA:(NSString *)upce;

@end
