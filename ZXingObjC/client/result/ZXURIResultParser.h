#import "ZXResultParser.h"

/**
 * Tries to parse results that are a URI of some kind.
 */

@class ZXResult, ZXURIParsedResult;

@interface ZXURIResultParser : ZXResultParser

+ (ZXURIParsedResult *)parse:(ZXResult *)result;
+ (BOOL)isBasicallyValidURI:(NSString *)uri;

@end
