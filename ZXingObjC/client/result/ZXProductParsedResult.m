#import "ZXProductParsedResult.h"

@interface ZXProductParsedResult ()

@property (nonatomic, copy) NSString * normalizedProductID;
@property (nonatomic, copy) NSString * productID;

@end

@implementation ZXProductParsedResult

@synthesize normalizedProductID;
@synthesize productID;

- (id)initWithProductID:(NSString *)aProductID {
  return [self initWithProductID:aProductID normalizedProductID:aProductID];
}

- (id)initWithProductID:(NSString *)aProductID normalizedProductID:(NSString *)aNormalizedProductID {
  if (self = [super initWithType:kParsedResultTypeProduct]) {
    self.normalizedProductID = aNormalizedProductID;
    self.productID = aProductID;
  }

  return self;
}

- (void) dealloc {
  [productID release];
  [normalizedProductID release];

  [super dealloc];
}

@end
