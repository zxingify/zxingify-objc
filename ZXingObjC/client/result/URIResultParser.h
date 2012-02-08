#import "ResultParser.h"

/**
 * Tries to parse results that are a URI of some kind.
 * 
 * @author Sean Owen
 */

@class Result, URIParsedResult;

@interface URIResultParser : ResultParser

+ (URIParsedResult *) parse:(Result *)result;
+ (BOOL) isBasicallyValidURI:(NSString *)uri;

@end
