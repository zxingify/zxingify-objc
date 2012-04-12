#import "ZXResultParser.h"

/**
 * Parses a "tel:" URI result, which specifies a phone number.
 * 
 * @author Sean Owen
 */

@class ZXResult, ZXTelParsedResult;

@interface ZXTelResultParser : ZXResultParser

+ (ZXTelParsedResult *) parse:(ZXResult *)result;

@end
