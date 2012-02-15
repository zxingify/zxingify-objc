#import "ResultParser.h"

/**
 * Parses strings of digits that represent a ISBN.
 * 
 * @author jbreiden@google.com (Jeff Breidenbach)
 */

@class ISBNParsedResult, Result;

@interface ISBNResultParser : ResultParser

+ (ISBNParsedResult *) parse:(Result *)result;

@end
