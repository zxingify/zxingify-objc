#import "BarcodeFormat.h"
#import "Result.h"
#import "UPCEReader.h"

/**
 * Parses strings of digits that represent a UPC code.
 * 
 * @author dswitkin@google.com (Daniel Switkin)
 */

@interface ProductResultParser : ResultParser {
}

+ (ProductParsedResult *) parse:(Result *)result;
@end
