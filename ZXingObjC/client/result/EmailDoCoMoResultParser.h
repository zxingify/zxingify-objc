#import "Result.h"

/**
 * Implements the "MATMSG" email message entry format.
 * 
 * Supported keys: TO, SUB, BODY
 * 
 * @author Sean Owen
 */

@interface EmailDoCoMoResultParser : AbstractDoCoMoResultParser {
}

+ (EmailAddressParsedResult *) parse:(Result *)result;
+ (BOOL) isBasicallyValidEmailAddress:(NSString *)email;
@end
