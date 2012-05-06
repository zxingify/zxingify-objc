#import "ZXResultParser.h"

/**
 * Parses strings of digits that represent a RSS Extended code.
 */

@class ZXExpandedProductParsedResult, ZXResult;

@interface ZXExpandedProductResultParser : ZXResultParser

+ (ZXExpandedProductParsedResult *)parse:(ZXResult *)result;

@end
