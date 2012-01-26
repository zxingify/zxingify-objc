#import "Result.h"

/**
 * Tries to parse results that are a URI of some kind.
 * 
 * @author Sean Owen
 */

@interface URIResultParser : ResultParser {
}

+ (URIParsedResult *) parse:(Result *)result;
+ (BOOL) isBasicallyValidURI:(NSString *)uri;
@end
