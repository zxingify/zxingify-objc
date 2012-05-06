/**
 * Parses an "smtp:" URI result, whose format is not standardized but appears to be like:
 * smtp(:subject(:body)).
 * 
 * See http://code.google.com/p/zxing/issues/detail?id=536
 */

@class ZXEmailAddressParsedResult, ZXResult;

@interface ZXSMTPResultParser : NSObject

+ (ZXEmailAddressParsedResult *)parse:(ZXResult *)result;

@end
