#import "Result.h"
#import "NSMutableArray.h"

/**
 * Implements the "BIZCARD" address book entry format, though this has been
 * largely reverse-engineered from examples observed in the wild -- still
 * looking for a definitive reference.
 * 
 * @author Sean Owen
 */

@interface BizcardResultParser : AbstractDoCoMoResultParser {
}

+ (AddressBookParsedResult *) parse:(Result *)result;
@end
