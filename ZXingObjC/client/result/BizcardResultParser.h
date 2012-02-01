#import "AbstractDoCoMoResultParser.h"

/**
 * Implements the "BIZCARD" address book entry format, though this has been
 * largely reverse-engineered from examples observed in the wild -- still
 * looking for a definitive reference.
 * 
 * @author Sean Owen
 */

@class AddressBookParsedResult, Result;

@interface BizcardResultParser : AbstractDoCoMoResultParser

+ (AddressBookParsedResult *) parse:(Result *)result;

@end
