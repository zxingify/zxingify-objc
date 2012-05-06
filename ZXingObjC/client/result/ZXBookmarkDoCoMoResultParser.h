#import "ZXAbstractDoCoMoResultParser.h"

@class ZXResult, ZXURIParsedResult;

@interface ZXBookmarkDoCoMoResultParser : ZXAbstractDoCoMoResultParser

+ (ZXURIParsedResult *)parse:(ZXResult *)result;

@end
