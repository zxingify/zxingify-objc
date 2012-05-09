#import "ZXBarcodeFormat.h"
#import "ZXUPCEANReader.h"

/**
 * Implements decoding of the UPC-E format.
 * 
 * http://www.barcodeisland.com/upce.phtml is a great reference for UPC-E information.
 */

@interface ZXUPCEReader : ZXUPCEANReader

+ (NSString *)convertUPCEtoUPCA:(NSString *)upce;

@end
