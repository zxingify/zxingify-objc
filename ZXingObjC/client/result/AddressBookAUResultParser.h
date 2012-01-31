#import "ResultParser.h"

/**
 * Implements KDDI AU's address book format. See
 * <a href="http://www.au.kddi.com/ezfactory/tec/two_dimensions/index.html">
 * http://www.au.kddi.com/ezfactory/tec/two_dimensions/index.html</a>.
 * (Thanks to Yuzo for translating!)
 * 
 * @author Sean Owen
 */

@class AddressBookParsedResult, Result;

@interface AddressBookAUResultParser : ResultParser

+ (AddressBookParsedResult *) parse:(Result *)result;

@end
