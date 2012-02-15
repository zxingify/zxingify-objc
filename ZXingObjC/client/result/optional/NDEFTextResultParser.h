#import "AbstractNDEFResultParser.h"

/**
 * Recognizes an NDEF message that encodes text according to the
 * "Text Record Type Definition" specification.
 * 
 * @author Sean Owen
 */

@class Result, TextParsedResult;

@interface NDEFTextResultParser : AbstractNDEFResultParser

+ (TextParsedResult *) parse:(Result *)result;
+ (NSArray *) decodeTextPayload:(NSArray *)payload;

@end
