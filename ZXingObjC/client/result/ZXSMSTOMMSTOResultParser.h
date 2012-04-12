#import "ZXResultParser.h"

/**
 * <p>Parses an "smsto:" URI result, whose format is not standardized but appears to be like:
 * <code>smsto:number(:body)</code>.</p>
 * 
 * <p>This actually also parses URIs starting with "smsto:", "mmsto:", "SMSTO:", and
 * "MMSTO:", and treats them all the same way, and effectively converts them to an "sms:" URI
 * for purposes of forwarding to the platform.</p>
 * 
 * @author Sean Owen
 */

@class ZXSMSParsedResult, ZXResult;

@interface ZXSMSTOMMSTOResultParser : ZXResultParser

+ (ZXSMSParsedResult *) parse:(ZXResult *)result;

@end
