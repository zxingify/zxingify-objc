#import "AbstractDoCoMoResultParser.h"

/**
 * @author Sean Owen
 */

@class Result, URIParsedResult;

@interface BookmarkDoCoMoResultParser : AbstractDoCoMoResultParser

+ (URIParsedResult *) parse:(Result *)result;

@end
