#import "ZXParsedResult.h"

/**
 * @author dswitkin@google.com (Daniel Switkin)
 */

@interface ZXProductParsedResult : ZXParsedResult {
  NSString * productID;
  NSString * normalizedProductID;
}

@property(nonatomic, retain, readonly) NSString * productID;
@property(nonatomic, retain, readonly) NSString * normalizedProductID;
@property(nonatomic, retain, readonly) NSString * displayResult;
- (id) initWithProductID:(NSString *)productID;
- (id) initWithProductID:(NSString *)productID normalizedProductID:(NSString *)normalizedProductID;

@end
