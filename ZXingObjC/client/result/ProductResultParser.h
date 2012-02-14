#import "ResultParser.h"

/**
 * Parses strings of digits that represent a UPC code.
 * 
 * @author dswitkin@google.com (Daniel Switkin)
 */

@class ProductParsedResult, Result;

@interface ProductResultParser : ResultParser

+ (ProductParsedResult *) parse:(Result *)result;

@end
