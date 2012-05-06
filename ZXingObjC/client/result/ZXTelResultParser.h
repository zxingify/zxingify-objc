#import "ZXResultParser.h"

/**
 * Parses a "tel:" URI result, which specifies a phone number.
 */

@class ZXResult, ZXTelParsedResult;

@interface ZXTelResultParser : ZXResultParser

+ (ZXTelParsedResult *)parse:(ZXResult *)result;

@end
