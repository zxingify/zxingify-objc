#import "Result.h"
#import "TextParsedResult.h"

/**
 * Recognizes an NDEF message that encodes text according to the
 * "Text Record Type Definition" specification.
 * 
 * @author Sean Owen
 */

@interface NDEFTextResultParser : AbstractNDEFResultParser {
}

+ (TextParsedResult *) parse:(Result *)result;
+ (NSArray *) decodeTextPayload:(NSArray *)payload;
@end
