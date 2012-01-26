#import "ProductParsedResult.h"

@implementation ProductParsedResult

@synthesize productID;
@synthesize normalizedProductID;
@synthesize displayResult;

- (id) initWithProductID:(NSString *)productID {
  if (self = [self init:productID normalizedProductID:productID]) {
  }
  return self;
}

- (id) init:(NSString *)productID normalizedProductID:(NSString *)normalizedProductID {
  if (self = [super init:ParsedResultType.PRODUCT]) {
    productID = productID;
    normalizedProductID = normalizedProductID;
  }
  return self;
}

- (void) dealloc {
  [productID release];
  [normalizedProductID release];
  [super dealloc];
}

@end
