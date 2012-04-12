#import "ZXAbstractNDEFResultParser.h"

/**
 * Recognizes an NDEF message that encodes text according to the
 * "Text Record Type Definition" specification.
 * 
 * @author Sean Owen
 */

@class ZXResult, ZXTextParsedResult;

@interface ZXNDEFTextResultParser : ZXAbstractNDEFResultParser

+ (ZXTextParsedResult *) parse:(ZXResult *)result;
+ (NSArray *) decodeTextPayload:(unsigned char *)payload length:(unsigned int)length;

@end
