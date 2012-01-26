#import "Result.h"

/**
 * Parses a "tel:" URI result, which specifies a phone number.
 * 
 * @author Sean Owen
 */

@interface TelResultParser : ResultParser {
}

+ (TelParsedResult *) parse:(Result *)result;
@end
