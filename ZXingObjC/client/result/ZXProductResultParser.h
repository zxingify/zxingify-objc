#import "ZXResultParser.h"

/**
 * Parses strings of digits that represent a UPC code.
 */

@class ZXProductParsedResult, ZXResult;

@interface ZXProductResultParser : ZXResultParser

+ (ZXProductParsedResult *)parse:(ZXResult *)result;

@end
