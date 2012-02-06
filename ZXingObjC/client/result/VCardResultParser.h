#import "Result.h"
#import "UnsupportedEncodingException.h"

/**
 * Parses contact information formatted according to the VCard (2.1) format. This is not a complete
 * implementation but should parse information as commonly encoded in 2D barcodes.
 * 
 * @author Sean Owen
 */

@interface VCardResultParser : ResultParser {
}

+ (AddressBookParsedResult *) parse:(Result *)result;
+ (NSString *) matchSingleVCardPrefixedField:(NSString *)prefix rawText:(NSString *)rawText trim:(BOOL)trim;
@end
