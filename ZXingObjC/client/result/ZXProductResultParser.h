#import "ZXResultParser.h"

/**
 * Parses strings of digits that represent a UPC code.
 * 
 * @author dswitkin@google.com (Daniel Switkin)
 */

@class ZXProductParsedResult, ZXResult;

@interface ZXProductResultParser : ZXResultParser

+ (ZXProductParsedResult *) parse:(ZXResult *)result;

@end
