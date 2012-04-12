#import "ZXResultParser.h"

/**
 * Parses strings of digits that represent a RSS Extended code.
 * 
 * @author Antonio Manuel Benjumea Conde, Servinform, S.A.
 * @author Agustín Delgado, Servinform, S.A.
 */

@class ZXExpandedProductParsedResult, ZXResult;

@interface ZXExpandedProductResultParser : ZXResultParser

+ (ZXExpandedProductParsedResult *) parse:(ZXResult *)result;

@end
