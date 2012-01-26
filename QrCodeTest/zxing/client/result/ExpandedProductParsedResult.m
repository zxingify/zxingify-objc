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
  if (self = [super init:ParsedResultType.PRODUCT]) {
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

- (id) init:(NSString *)productID sscc:(NSString *)sscc lotNumber:(NSString *)lotNumber productionDate:(NSString *)productionDate packagingDate:(NSString *)packagingDate bestBeforeDate:(NSString *)bestBeforeDate expirationDate:(NSString *)expirationDate weight:(NSString *)weight weightType:(NSString *)weightType weightIncrement:(NSString *)weightIncrement price:(NSString *)price priceIncrement:(NSString *)priceIncrement priceCurrency:(NSString *)priceCurrency uncommonAIs:(NSMutableDictionary *)uncommonAIs {
  if (self = [super init:ParsedResultType.PRODUCT]) {
    productID = productID;
    sscc = sscc;
    lotNumber = lotNumber;
    productionDate = productionDate;
    packagingDate = packagingDate;
    bestBeforeDate = bestBeforeDate;
    expirationDate = expirationDate;
    weight = weight;
    weightType = weightType;
    weightIncrement = weightIncrement;
    price = price;
    priceIncrement = priceIncrement;
    priceCurrency = priceCurrency;
    uncommonAIs = uncommonAIs;
  }
  return self;
}

- (BOOL) isEqualTo:(NSObject *)o {
  if (!([o conformsToProtocol:@protocol(ExpandedProductParsedResult)])) {
    return NO;
  }
  ExpandedProductParsedResult * other = (ExpandedProductParsedResult *)o;
  return [productID isEqualTo:other.productID] && [sscc isEqualTo:other.sscc] && [lotNumber isEqualTo:other.lotNumber] && [productionDate isEqualTo:other.productionDate] && [bestBeforeDate isEqualTo:other.bestBeforeDate] && [expirationDate isEqualTo:other.expirationDate] && [weight isEqualTo:other.weight] && [weightType isEqualTo:other.weightType] && [weightIncrement isEqualTo:other.weightIncrement] && [price isEqualTo:other.price] && [priceIncrement isEqualTo:other.priceIncrement] && [priceCurrency isEqualTo:other.priceCurrency] && [uncommonAIs isEqualTo:other.uncommonAIs];
}

- (int) hash {
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
