
/**
 * @author dswitkin@google.com (Daniel Switkin)
 */

@interface ProductParsedResult : ParsedResult {
  NSString * productID;
  NSString * normalizedProductID;
}

@property(nonatomic, retain, readonly) NSString * productID;
@property(nonatomic, retain, readonly) NSString * normalizedProductID;
@property(nonatomic, retain, readonly) NSString * displayResult;
- (id) initWithProductID:(NSString *)productID;
- (id) init:(NSString *)productID normalizedProductID:(NSString *)normalizedProductID;
@end
