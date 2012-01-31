#import "ExpandedProductParsedResult.h"
#import "Result.h"
#import "ResultParser.h"

/**
 * Parses strings of digits that represent a RSS Extended code.
 * 
 * @author Antonio Manuel Benjumea Conde, Servinform, S.A.
 * @author Agustín Delgado, Servinform, S.A.
 */

@interface ExpandedProductResultParser : ResultParser

+ (ExpandedProductParsedResult *) parse:(Result *)result;

@end
