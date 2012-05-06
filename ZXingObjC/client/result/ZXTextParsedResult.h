#import "ZXParsedResult.h"

/**
 * A simple result type encapsulating a string that has no further
 * interpretation.
 */

@interface ZXTextParsedResult : ZXParsedResult

@property (nonatomic, copy, readonly) NSString * text;
@property (nonatomic, copy, readonly) NSString * language;

- (id)initWithText:(NSString *)text language:(NSString *)language;

@end
