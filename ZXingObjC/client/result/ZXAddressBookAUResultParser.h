#import "ZXResultParser.h"

/**
 * Implements KDDI AU's address book format. See http://www.au.kddi.com/ezfactory/tec/two_dimensions/index.html.
 * (Thanks to Yuzo for translating!)
 */

@class ZXAddressBookParsedResult, ZXResult;

@interface ZXAddressBookAUResultParser : ZXResultParser

+ (ZXAddressBookParsedResult *)parse:(ZXResult *)result;

@end
