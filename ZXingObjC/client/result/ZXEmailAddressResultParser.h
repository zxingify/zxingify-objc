#import "ZXResultParser.h"

/**
 * Represents a result that encodes an e-mail address, either as a plain address
 * like "joe@example.org" or a mailto: URL like "mailto:joe@example.org".
 */

@class ZXEmailAddressParsedResult, ZXResult;

@interface ZXEmailAddressResultParser : ZXResultParser

+ (ZXEmailAddressParsedResult *)parse:(ZXResult *)result;

@end
