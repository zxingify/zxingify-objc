#import "AbstractDoCoMoResultParser.h"

/**
 * Implements the "MATMSG" email message entry format.
 * 
 * Supported keys: TO, SUB, BODY
 * 
 * @author Sean Owen
 */

@class EmailAddressParsedResult, Result;

@interface EmailDoCoMoResultParser : AbstractDoCoMoResultParser

+ (EmailAddressParsedResult *) parse:(Result *)result;
+ (BOOL) isBasicallyValidEmailAddress:(NSString *)email;

@end
