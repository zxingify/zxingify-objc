/**
 * Parses the "URLTO" result format, which is of the form "URLTO:[title]:[url]".
 * This seems to be used sometimes, but I am not able to find documentation
 * on its origin or official format?
 */

@class ZXResult, ZXURIParsedResult;

@interface ZXURLTOResultParser : NSObject

+ (ZXURIParsedResult *)parse:(ZXResult *)result;

@end
