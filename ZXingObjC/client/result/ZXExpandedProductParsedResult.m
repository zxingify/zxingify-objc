#import "ZXExpandedProductParsedResult.h"

NSString * const KILOGRAM = @"KG";
NSString * const POUND = @"LB";

@interface ZXExpandedProductParsedResult ()

@property (nonatomic, copy) NSString * productID;
@property (nonatomic, copy) NSString * sscc;
@property (nonatomic, copy) NSString * lotNumber;
@property (nonatomic, copy) NSString * productionDate;
@property (nonatomic, copy) NSString * packagingDate;
@property (nonatomic, copy) NSString * bestBeforeDate;
@property (nonatomic, copy) NSString * expirationDate;
@property (nonatomic, copy) NSString * weight;
@property (nonatomic, copy) NSString * weightType;
@property (nonatomic, copy) NSString * weightIncrement;
@property (nonatomic, copy) NSString * price;
@property (nonatomic, copy) NSString * priceIncrement;
@property (nonatomic, copy) NSString * priceCurrency;
@property (nonatomic, retain) NSMutableDictionary * uncommonAIs;

@end

@implementation ZXExpandedProductParsedResult

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

- (id)init {
  return [self initWithProductID:@"" sscc:@"" lotNumber:@"" productionDate:@"" packagingDate:@"" bestBeforeDate:@"" expirationDate:@"" weight:@"" weightType:@"" weightIncrement:@"" price:@"" priceIncrement:@"" priceCurrency:@"" uncommonAIs:[NSMutableDictionary dictionary]];
}

- (id)initWithProductID:(NSString *)aProductID
                   sscc:(NSString *)anSscc
              lotNumber:(NSString *)aLotNumber
         productionDate:(NSString *)aProductionDate
          packagingDate:(NSString *)aPackagingDate
         bestBeforeDate:(NSString *)aBestBeforeDate
         expirationDate:(NSString *)anExpirationDate
                 weight:(NSString *)aWeight
             weightType:(NSString *)aWeightType
        weightIncrement:(NSString *)aWeightIncrement
                  price:(NSString *)aPrice
         priceIncrement:(NSString *)aPriceIncrement
          priceCurrency:(NSString *)aPriceCurrency
            uncommonAIs:(NSMutableDictionary *)theUncommonAIs {
  self = [super initWithType:kParsedResultTypeProduct];
  if (self) {
    self.productID = aProductID;
    self.sscc = anSscc;
    self.lotNumber = aLotNumber;
    self.productionDate = aProductionDate;
    self.packagingDate = aPackagingDate;
    self.bestBeforeDate = aBestBeforeDate;
    self.expirationDate = anExpirationDate;
    self.weight = aWeight;
    self.weightType = aWeightType;
    self.weightIncrement = aWeightIncrement;
    self.price = aPrice;
    self.priceIncrement = aPriceIncrement;
    self.priceCurrency = aPriceCurrency;
    self.uncommonAIs = theUncommonAIs;
  }

  return self;
}

- (void)dealloc {
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

- (BOOL)isEqual:(id)o {
  if (![o isKindOfClass:[self class]]) {
    return NO;
  }

  ZXExpandedProductParsedResult * other = (ZXExpandedProductParsedResult *)o;

  return [productID isEqualToString:other.productID] &&
    [sscc isEqualToString:other.sscc] &&
    [lotNumber isEqualToString:other.lotNumber] &&
    [productionDate isEqualToString:other.productionDate] &&
    [bestBeforeDate isEqualToString:other.bestBeforeDate] &&
    [expirationDate isEqualToString:other.expirationDate] &&
    [weight isEqualToString:other.weight] &&
    [weightType isEqualToString:other.weightType] &&
    [weightIncrement isEqualToString:other.weightIncrement] &&
    [price isEqualToString:other.price] &&
    [priceIncrement isEqualToString:other.priceIncrement] &&
    [priceCurrency isEqualToString:other.priceCurrency] &&
    [uncommonAIs isEqual:other.uncommonAIs];
}

- (NSUInteger)hash {
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

@end
