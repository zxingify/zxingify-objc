#import "ZXAbstractNDEFResultParser.h"

/**
 * Recognizes an NDEF message that encodes a URI according to the
 * "URI Record Type Definition" specification.
 */

@class ZXResult, ZXURIParsedResult;

@interface ZXNDEFURIResultParser : ZXAbstractNDEFResultParser

+ (ZXURIParsedResult *)parse:(ZXResult *)result;
+ (NSString *)decodeURIPayload:(unsigned char *)payload length:(unsigned int)length;

@end
