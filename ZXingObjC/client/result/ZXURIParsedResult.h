#import "ZXParsedResult.h"

@interface ZXURIParsedResult : ZXParsedResult

@property (nonatomic, copy, readonly) NSString * uri;
@property (nonatomic, copy, readonly) NSString * title;

- (id)initWithUri:(NSString *)uri title:(NSString *)title;
- (BOOL)possiblyMaliciousURI;

@end
