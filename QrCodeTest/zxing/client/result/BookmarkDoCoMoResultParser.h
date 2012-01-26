#import "Result.h"

/**
 * @author Sean Owen
 */

@interface BookmarkDoCoMoResultParser : AbstractDoCoMoResultParser {
}

+ (URIParsedResult *) parse:(Result *)result;
@end
