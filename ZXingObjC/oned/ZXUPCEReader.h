#import "ZXBarcodeFormat.h"
#import "ZXUPCEANReader.h"

/**
 * <p>Implements decoding of the UPC-E format.</p>
 * <p/>
 * <p><a href="http://www.barcodeisland.com/upce.phtml">This</a> is a great reference for
 * UPC-E information.</p>
 * 
 * @author Sean Owen
 */

@interface ZXUPCEReader : ZXUPCEANReader {
  int decodeMiddleCounters[4];
}

@property (nonatomic, readonly) ZXBarcodeFormat barcodeFormat;

+ (NSString *) convertUPCEtoUPCA:(NSString *)upce;

@end
