#import "ZXResultParser.h"

/**
 * Parses strings of digits that represent a ISBN.
 * 
 * @author jbreiden@google.com (Jeff Breidenbach)
 */

@class ZXISBNParsedResult, ZXResult;

@interface ZXISBNResultParser : ZXResultParser

+ (ZXISBNParsedResult *) parse:(ZXResult *)result;

@end
