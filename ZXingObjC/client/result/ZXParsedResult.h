#import "ZXParsedResultType.h"
#import "ZXResult.h"

/**
 * Abstract class representing the result of decoding a barcode, as more than
 * a String -- as some type of structured data. This might be a subclass which represents
 * a URL, or an e-mail address. parseResult() will turn a raw
 * decoded string into the most appropriate type of structured representation.
 * 
 * Thanks to Jeff Griffin for proposing rewrite of these classes that relies less
 * on exception-based mechanisms during parsing.
 */

@interface ZXParsedResult : NSObject

@property (nonatomic, readonly) ZXParsedResultType type;

- (id)initWithType:(ZXParsedResultType)type;
- (NSString *)displayResult;
+ (void)maybeAppend:(NSString *)value result:(NSMutableString *)result;
+ (void)maybeAppendArray:(NSArray *)value result:(NSMutableString *)result;

@end
