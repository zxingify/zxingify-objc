#import "ZXResultParser.h"

/**
 * Parses strings of digits that represent a ISBN.
 */

@class ZXISBNParsedResult, ZXResult;

@interface ZXISBNResultParser : ZXResultParser

+ (ZXISBNParsedResult *)parse:(ZXResult *)result;

@end
