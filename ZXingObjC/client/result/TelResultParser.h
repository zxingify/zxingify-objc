#import "ResultParser.h"

/**
 * Parses a "tel:" URI result, which specifies a phone number.
 * 
 * @author Sean Owen
 */

@class Result, TelParsedResult;

@interface TelResultParser : ResultParser

+ (TelParsedResult *) parse:(Result *)result;

@end
