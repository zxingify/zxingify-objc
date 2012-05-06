#import "ZXResultParser.h"

/**
 * See DoCoMo's documentation http://www.nttdocomo.co.jp/english/service/imode/make/content/barcode/about/s2.html
 * about the result types represented by subclasses of this class.
 */

@interface ZXAbstractDoCoMoResultParser : ZXResultParser

+ (NSArray *)matchDoCoMoPrefixedField:(NSString *)prefix rawText:(NSString *)rawText trim:(BOOL)trim;
+ (NSString *)matchSingleDoCoMoPrefixedField:(NSString *)prefix rawText:(NSString *)rawText trim:(BOOL)trim;

@end
