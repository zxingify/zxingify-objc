#import "AbstractNDEFResultParser.h"

/**
 * Recognizes an NDEF message that encodes a URI according to the
 * "URI Record Type Definition" specification.
 * 
 * @author Sean Owen
 */

@class Result, URIParsedResult;

@interface NDEFURIResultParser : AbstractNDEFResultParser

+ (URIParsedResult *) parse:(Result *)result;
+ (NSString *) decodeURIPayload:(char *)payload;

@end
