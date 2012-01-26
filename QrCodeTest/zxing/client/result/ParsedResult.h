#import "Result.h"

/**
 * <p>Abstract class representing the result of decoding a barcode, as more than
 * a String -- as some type of structured data. This might be a subclass which represents
 * a URL, or an e-mail address. {@link ResultParser#parseResult(Result)} will turn a raw
 * decoded string into the most appropriate type of structured representation.</p>
 * 
 * <p>Thanks to Jeff Griffin for proposing rewrite of these classes that relies less
 * on exception-based mechanisms during parsing.</p>
 * 
 * @author Sean Owen
 */

@interface ParsedResult : NSObject {
  ParsedResultType * type;
}

@property(nonatomic, retain, readonly) ParsedResultType * type;
@property(nonatomic, retain, readonly) NSString * displayResult;
- (id) initWithType:(ParsedResultType *)type;
- (NSString *) description;
+ (void) maybeAppend:(NSString *)value result:(StringBuffer *)result;
+ (void) maybeAppend:(NSArray *)value result:(StringBuffer *)result;
@end
