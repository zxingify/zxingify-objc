#import "Result.h"

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

@interface SMSTOMMSTOResultParser : ResultParser {
}

+ (SMSParsedResult *) parse:(Result *)result;
@end
