#import "BarcodeFormat.h"
#import "ISBNParsedResult.h"
#import "Result.h"
#import "ResultParser.h"

/**
 * Parses strings of digits that represent a ISBN.
 * 
 * @author jbreiden@google.com (Jeff Breidenbach)
 */

@interface ISBNResultParser : ResultParser

+ (ISBNParsedResult *) parse:(Result *)result;

@end
