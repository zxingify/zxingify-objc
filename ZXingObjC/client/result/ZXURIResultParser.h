#import "ZXResultParser.h"

/**
 * Tries to parse results that are a URI of some kind.
 * 
 * @author Sean Owen
 */

@class ZXResult, ZXURIParsedResult;

@interface ZXURIResultParser : ZXResultParser

+ (ZXURIParsedResult *) parse:(ZXResult *)result;
+ (BOOL) isBasicallyValidURI:(NSString *)uri;

@end
