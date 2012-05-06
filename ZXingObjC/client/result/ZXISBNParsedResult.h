#import "ZXParsedResult.h"

@interface ZXISBNParsedResult : ZXParsedResult

@property (nonatomic, copy, readonly) NSString * isbn;

- (id)initWithIsbn:(NSString *)isbn;

@end
