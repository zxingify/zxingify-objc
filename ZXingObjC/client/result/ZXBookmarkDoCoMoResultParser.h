#import "ZXAbstractDoCoMoResultParser.h"

/**
 * @author Sean Owen
 */

@class ZXResult, ZXURIParsedResult;

@interface ZXBookmarkDoCoMoResultParser : ZXAbstractDoCoMoResultParser

+ (ZXURIParsedResult *) parse:(ZXResult *)result;

@end
