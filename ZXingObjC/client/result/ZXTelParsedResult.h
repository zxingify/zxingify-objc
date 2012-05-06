#import "ZXParsedResult.h"

@interface ZXTelParsedResult : ZXParsedResult

@property (nonatomic, copy, readonly) NSString * number;
@property (nonatomic, copy, readonly) NSString * telURI;
@property (nonatomic, copy, readonly) NSString * title;

- (id)initWithNumber:(NSString *)number telURI:(NSString *)telURI title:(NSString *)title;

@end
