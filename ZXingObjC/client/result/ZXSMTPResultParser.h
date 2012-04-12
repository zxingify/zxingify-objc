/**
 * <p>Parses an "smtp:" URI result, whose format is not standardized but appears to be like:
 * <code>smtp(:subject(:body))</code>.</p>
 * 
 * <p>See http://code.google.com/p/zxing/issues/detail?id=536</p>
 * 
 * @author Sean Owen
 */

@class ZXEmailAddressParsedResult, ZXResult;

@interface ZXSMTPResultParser : NSObject

+ (ZXEmailAddressParsedResult *) parse:(ZXResult *)result;

@end
