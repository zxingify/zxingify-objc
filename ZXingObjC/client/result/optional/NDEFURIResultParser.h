#import "Result.h"
#import "URIParsedResult.h"

/**
 * Recognizes an NDEF message that encodes a URI according to the
 * "URI Record Type Definition" specification.
 * 
 * @author Sean Owen
 */

@interface NDEFURIResultParser : AbstractNDEFResultParser {
}

+ (URIParsedResult *) parse:(Result *)result;
+ (NSString *) decodeURIPayload:(NSArray *)payload;
@end
