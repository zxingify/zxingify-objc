#import "ResultParser.h"

/**
 * Represents a result that encodes an e-mail address, either as a plain address
 * like "joe@example.org" or a mailto: URL like "mailto:joe@example.org".
 * 
 * @author Sean Owen
 */

@class EmailAddressParsedResult, Result;

@interface EmailAddressResultParser : ResultParser

+ (EmailAddressParsedResult *) parse:(Result *)result;

@end
