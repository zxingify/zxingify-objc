#import "ZXParsedResult.h"

@interface ZXProductParsedResult : ZXParsedResult

@property (nonatomic, copy, readonly) NSString * normalizedProductID;
@property (nonatomic, copy, readonly) NSString * productID;

- (id)initWithProductID:(NSString *)productID;
- (id)initWithProductID:(NSString *)productID normalizedProductID:(NSString *)normalizedProductID;

@end
