#import "ZXResultParser.h"

/**
 * Parses contact information formatted according to the VCard (2.1) format. This is not a complete
 * implementation but should parse information as commonly encoded in 2D barcodes.
 */

@class ZXAddressBookParsedResult, ZXResult;

@interface ZXVCardResultParser : ZXResultParser

+ (ZXAddressBookParsedResult *)parse:(ZXResult *)result;
+ (NSString *)matchSingleVCardPrefixedField:(NSString *)prefix rawText:(NSString *)rawText trim:(BOOL)trim;

@end
