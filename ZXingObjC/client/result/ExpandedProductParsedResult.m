#import "ExpandedProductParsedResult.h"

NSString * const KILOGRAM = @"KG";
NSString * const POUND = @"LB";

@implementation ExpandedProductParsedResult

@synthesize productID;
@synthesize sscc;
@synthesize lotNumber;
@synthesize productionDate;
@synthesize packagingDate;
@synthesize bestBeforeDate;
@synthesize expirationDate;
@synthesize weight;
@synthesize weightType;
@synthesize weightIncrement;
@synthesize price;
@synthesize priceIncrement;
@synthesize priceCurrency;
@synthesize uncommonAIs;
@synthesize displayResult;

- (id) init {
  if (self = [super initWithType:kParsedResultTypeProduct]) {
    productID = @"";
    sscc = @"";
    lotNumber = @"";
    productionDate = @"";
    packagingDate = @"";
    bestBeforeDate = @"";
    expirationDate = @"";
    weight = @"";
    weightType = @"";
    weightIncrement = @"";
    price = @"";
    priceIncrement = @"";
    priceCurrency = @"";
    uncommonAIs = [[[NSMutableDictionary alloc] init] autorelease];
  }
  return self;
}

- (id) init:(NSString *)aProductID sscc:(NSString *)anSscc lotNumber:(NSString *)aLotNumber productionDate:(NSString *)aProductionDate packagingDate:(NSString *)aPackagingDate bestBeforeDate:(NSString *)aBestBeforeDate expirationDate:(NSString *)anExpirationDate weight:(NSString *)aWeight weightType:(NSString *)aWeightType weightIncrement:(NSString *)aWeightIncrement price:(NSString *)aPrice priceIncrement:(NSString *)aPriceIncrement priceCurrency:(NSString *)aPriceCurrency uncommonAIs:(NSMutableDictionary *)theUncommonAIs {
  if (self = [super initWithType:kParsedResultTypeProduct]) {
    productID = [aProductID copy];
    sscc = [anSscc copy];
    lotNumber = [aLotNumber copy];
    productionDate = [aProductionDate copy];
    packagingDate = [aPackagingDate copy];
    bestBeforeDate = [aBestBeforeDate copy];
    expirationDate = [anExpirationDate copy];
    weight = [aWeight copy];
    weightType = [aWeightType copy];
    weightIncrement = [aWeightIncrement copy];
    price = [aPrice copy];
    priceIncrement = [aPriceIncrement copy];
    priceCurrency = [aPriceCurrency copy];
    uncommonAIs = [theUncommonAIs copy];
  }
  return self;
}

- (BOOL)isEqual:(id)o {
  if (![o isKindOfClass:[self class]]) {
    return NO;
  }
  ExpandedProductParsedResult * other = (ExpandedProductParsedResult *)o;
  return [productID isEqualToString:other.productID] && [sscc isEqualToString:other.sscc] && [lotNumber isEqualToString:other.lotNumber] && [productionDate isEqualToString:other.productionDate] && [bestBeforeDate isEqualToString:other.bestBeforeDate] && [expirationDate isEqualToString:other.expirationDate] && [weight isEqualToString:other.weight] && [weightType isEqualToString:other.weightType] && [weightIncrement isEqualToString:other.weightIncrement] && [price isEqualToString:other.price] && [priceIncrement isEqualToString:other.priceIncrement] && [priceCurrency isEqualToString:other.priceCurrency] && [uncommonAIs isEqual:other.uncommonAIs];
}

- (NSUInteger) hash {
  int hash1 = [productID hash];
  hash1 = 31 * hash1 + [sscc hash];
  hash1 = 31 * hash1 + [lotNumber hash];
  hash1 = 31 * hash1 + [productionDate hash];
  hash1 = 31 * hash1 + [bestBeforeDate hash];
  hash1 = 31 * hash1 + [expirationDate hash];
  hash1 = 31 * hash1 + [weight hash];
  int hash2 = [weightType hash];
  hash2 = 31 * hash2 + [weightIncrement hash];
  hash2 = 31 * hash2 + [price hash];
  hash2 = 31 * hash2 + [priceIncrement hash];
  hash2 = 31 * hash2 + [priceCurrency hash];
  hash2 = 31 * hash2 + [uncommonAIs hash];
  return hash1 ^ hash2;
}

- (void) dealloc {
  [productID release];
  [sscc release];
  [lotNumber release];
  [productionDate release];
  [packagingDate release];
  [bestBeforeDate release];
  [expirationDate release];
  [weight release];
  [weightType release];
  [weightIncrement release];
  [price release];
  [priceIncrement release];
  [priceCurrency release];
  [uncommonAIs release];
  [super dealloc];
}

@end
