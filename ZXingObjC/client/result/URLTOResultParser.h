#import "Result.h"

/**
 * Parses the "URLTO" result format, which is of the form "URLTO:[title]:[url]".
 * This seems to be used sometimes, but I am not able to find documentation
 * on its origin or official format?
 * 
 * @author Sean Owen
 */

@interface URLTOResultParser : NSObject {
}

+ (URIParsedResult *) parse:(Result *)result;
@end
