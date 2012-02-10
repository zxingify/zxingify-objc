#import "ProductParsedResult.h"

@implementation ProductParsedResult

@synthesize productID;
@synthesize normalizedProductID;
@synthesize displayResult;

- (id) initWithProductID:(NSString *)aProductID {
  self = [self initWithProductID:aProductID normalizedProductID:aProductID];
  return self;
}

- (id) initWithProductID:(NSString *)aProductID normalizedProductID:(NSString *)aNormalizedProductID {
  if (self = [super initWithType:kParsedResultTypeProduct]) {
    productID = [aProductID copy];
    normalizedProductID = [aNormalizedProductID copy];
  }
  return self;
}

- (void) dealloc {
  [productID release];
  [normalizedProductID release];
  [super dealloc];
}

@end
